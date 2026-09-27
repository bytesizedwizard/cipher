import 'dart:async';

import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/services/auth_service.dart';
import 'package:cipher/src/feature/account/services/totp_service.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/providers/app_lock_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

class AccountView {
  const AccountView({
    required this.account,
    required this.otp,
    required this.secondsLeft,
  });

  final Account account;
  final String otp;
  final int secondsLeft;
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  Timer? _ticker;
  List<Account> _accounts = [];
  Future<Map<String, AccountView>>? _activeRefresh;
  Future<void> _operationQueue = Future<void>.value();
  final Completer<void> _initialized = Completer<void>();
  var _locked = true;
  var _refreshGeneration = 0;

  AuthService get _authService => ref.read(authServiceProvider);
  TotpService get _totpService => ref.read(totpServiceProvider);

  @override
  Future<Map<String, AccountView>> build() async {
    ref.listen<AppLockStatus>(appLockControllerProvider, (_, next) {
      unawaited(
        _handleLockState(next).onError((Object error, StackTrace stackTrace) {
          state = AsyncError<Map<String, AccountView>>(
            _safeError(error),
            stackTrace,
          );
        }),
      );
    });
    ref.onDispose(() {
      _ticker?.cancel();
      _ticker = null;
    });
    _locked = ref.read(appLockControllerProvider) != AppLockStatus.unlocked;

    try {
      final migrationIssues = await _authService.migrateLegacyAccounts();
      _accounts = await _authService.getAccounts('');
      if (_accounts.isEmpty && migrationIssues.isNotEmpty) {
        throw migrationIssues.first;
      }

      if (_locked) {
        return const <String, AccountView>{};
      }

      final views = await _buildViews(_accounts);
      _startTicker();
      return Map.unmodifiable(views);
    } catch (error) {
      throw _safeError(error);
    } finally {
      if (!_initialized.isCompleted) {
        _initialized.complete();
      }
    }
  }

  Future<void> refreshAccounts(String query) {
    return _enqueue(() async {
      await _initialized.future;
      _accounts = await _authService.getAccounts(query);
      await _publishRefresh(forceLatest: true, propagateError: true);
    });
  }

  Future<void> addAccount(Account account, String secret) {
    return _enqueue(() async {
      await _initialized.future;
      await _authService.addAccount(account, secret);
      _accounts = await _authService.getAccounts('');
      await _publishRefresh(forceLatest: true, propagateError: true);
    });
  }

  Future<void> addAccountFromUri(String uri) async {
    final (account, secret) = _totpService.decode(uri);
    await addAccount(account, secret);
  }

  Future<void> deleteAccount(String id) {
    return _enqueue(() async {
      await _initialized.future;
      await _authService.deleteAccount(id);
      _accounts = await _authService.getAccounts('');
      await _publishRefresh(forceLatest: true, propagateError: true);
    });
  }

  Future<void> nextHotp(String id) {
    return _enqueue(() async {
      await _initialized.future;
      if (_locked) {
        return;
      }
      await _authService.advanceHotp(id);
      _accounts = await _authService.getAccounts('');
      await _publishRefresh(forceLatest: true, propagateError: true);
    });
  }

  void _startTicker() {
    if (_locked) {
      return;
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_publishRefresh(forceLatest: false, propagateError: false));
    });
  }

  Future<void> _publishRefresh({
    required bool forceLatest,
    required bool propagateError,
  }) async {
    try {
      final next = await _refreshViews(forceLatest: forceLatest);
      state = AsyncData(Map.unmodifiable(next));
    } catch (error, stackTrace) {
      if (error is _StaleRefreshException) {
        return;
      }
      final safeError = _safeError(error);
      final previous = state;
      final errorState = AsyncError<Map<String, AccountView>>(
        safeError,
        stackTrace,
      );
      // ignore: invalid_use_of_internal_member
      state = errorState.copyWithPrevious(previous, isRefresh: false);
      if (propagateError) {
        throw safeError;
      }
    }
  }

  Future<Map<String, AccountView>> _refreshViews({
    required bool forceLatest,
  }) async {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) {
      try {
        final previousResult = await activeRefresh;
        if (!forceLatest) {
          return previousResult;
        }
      } catch (_) {
        if (!forceLatest) {
          rethrow;
        }
      }
    }

    final refresh = _buildViews(List<Account>.of(_accounts));
    _activeRefresh = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_activeRefresh, refresh)) {
        _activeRefresh = null;
      }
    }
  }

  Future<Map<String, AccountView>> _buildViews(List<Account> accounts) async {
    final generation = _refreshGeneration;
    final nowUtc = DateTime.now().toUtc();
    final epoch = nowUtc.millisecondsSinceEpoch ~/ 1000;
    final next = <String, AccountView>{};

    for (final account in accounts) {
      if (_locked || generation != _refreshGeneration) {
        throw const _StaleRefreshException();
      }
      final otp = await _totpService.refresh(account);
      if (_locked || generation != _refreshGeneration) {
        throw const _StaleRefreshException();
      }
      final secondsLeft = account.type == AuthConstants.hotp
          ? 0
          : account.period - (epoch % account.period);
      next[account.id] = AccountView(
        account: account,
        otp: otp,
        secondsLeft: secondsLeft,
      );
    }

    return next;
  }

  Future<void> _handleLockState(AppLockStatus lockState) async {
    if (lockState != AppLockStatus.unlocked) {
      _locked = true;
      _refreshGeneration++;
      _ticker?.cancel();
      _ticker = null;
      state = const AsyncData(<String, AccountView>{});
      return;
    }

    _locked = false;
    await _enqueue(() async {
      await _initialized.future;
      if (_locked) {
        return;
      }
      _accounts = await _authService.getAccounts('');
      await _publishRefresh(forceLatest: true, propagateError: true);
      _startTicker();
    });
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = Completer<void>();
    final previous = _operationQueue;

    _operationQueue = () async {
      try {
        await previous;
      } catch (_) {
        // Previous operation already published its error.
      }

      try {
        await operation();
        result.complete();
      } catch (error, stackTrace) {
        final safeError = _safeError(error);
        if (!result.isCompleted) {
          result.completeError(safeError, stackTrace);
        }
        if (!_initialized.isCompleted) {
          _initialized.complete();
        }
        if (state.hasValue || state.hasError) {
          final previousState = state;
          final errorState = AsyncError<Map<String, AccountView>>(
            safeError,
            stackTrace,
          );
          // ignore: invalid_use_of_internal_member
          state = errorState.copyWithPrevious(previousState, isRefresh: false);
        }
      }
    }();

    return result.future;
  }

  Object _safeError(Object error) {
    if (error is AccountStorageIssue || error is ParseException) {
      return error;
    }
    return StateError('Unable to load accounts.');
  }
}

class _StaleRefreshException implements Exception {
  const _StaleRefreshException();
}
