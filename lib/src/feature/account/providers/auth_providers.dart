import 'dart:async';

import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/services/auth_service.dart';
import 'package:cipher/src/feature/account/services/totp_service.dart';
import 'package:flutter/widgets.dart';
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
class AuthController extends _$AuthController with WidgetsBindingObserver {
  Timer? _ticker;
  List<Account> _accounts = [];
  Future<Map<String, AccountView>>? _activeRefresh;
  Future<void> _operationQueue = Future<void>.value();
  final Completer<void> _initialized = Completer<void>();

  AuthService get _authService => ref.read(authServiceProvider);
  TotpService get _totpService => ref.read(totpServiceProvider);

  @override
  Future<Map<String, AccountView>> build() async {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _ticker?.cancel();
      _ticker = null;
    });

    try {
      final migrationIssues = await _authService.migrateLegacyAccounts();
      _accounts = await _authService.getAccounts('');
      if (_accounts.isEmpty && migrationIssues.isNotEmpty) {
        throw migrationIssues.first;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(
        _enqueue(() async {
          await _initialized.future;
          _accounts = await _authService.getAccounts('');
          await _publishRefresh(forceLatest: true, propagateError: true);
          _startTicker();
        }).catchError((_) {}),
      );
    }
  }

  void _startTicker() {
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
      final safeError = _safeError(error);
      final previous = state;
      state = AsyncError<Map<String, AccountView>>(
        safeError,
        stackTrace,
      ).copyWithPrevious(previous, isRefresh: false);
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
    final nowUtc = DateTime.now().toUtc();
    final epoch = nowUtc.millisecondsSinceEpoch ~/ 1000;
    final next = <String, AccountView>{};

    for (final account in accounts) {
      final otp = await _totpService.refresh(account);
      final secondsLeft = account.period - (epoch % account.period);
      next[account.id] = AccountView(
        account: account,
        otp: otp,
        secondsLeft: secondsLeft,
      );
    }

    return next;
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
          state = AsyncError<Map<String, AccountView>>(
            safeError,
            stackTrace,
          ).copyWithPrevious(previousState, isRefresh: false);
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
