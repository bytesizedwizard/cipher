// auth_controller.dart
import 'dart:async';

import 'package:cipher/src/feature/auth/models/auth_models.dart';
import 'package:cipher/src/feature/auth/services/auth_service.dart';
import 'package:cipher/src/feature/auth/services/totp_service.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

class AccountView {
  final Account account; // metadata
  final String otp; // transient
  final int secondsLeft;

  AccountView({
    required this.account,
    required this.otp,
    required this.secondsLeft,
  });
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController with WidgetsBindingObserver {
  Timer? _ticker;
  final Map<String, List<int>> _secretCache =
      {}; // optional caching of secret bytes
  List<Account> _accounts = [];

  AuthService get _authService => ref.read(authServiceProvider);
  TotpService get _totpService => ref.read(totpServiceProvider);

  @override
  Map<String, AccountView> build() {
    WidgetsBinding.instance.addObserver(this);

    // cleanup on provider disposal (use ref.onDispose instead of overriding dispose)
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _ticker?.cancel();
      _ticker = null;
    });

    // Start by loading accounts once (fire-and-forget)
    _loadAndStart();
    return {};
  }

  Future<void> _loadAndStart() async {
    _accounts = await _authService.getAccounts(); // metadata only
    // Optionally pre-load secrets into _secretCache by calling totp service
    // for (final a in _accounts) { _secretCache[a.id] = await _totpService.secretBytesFor(a); }
    _tick(); // immediate
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final nowUtc = DateTime.now().toUtc();
    final epoch = nowUtc.millisecondsSinceEpoch ~/ 1000;
    final Map<String, AccountView> next = {};

    for (final a in _accounts) {
      // either call generate with account+time, or use cached secret
      final otp = await _totpService.refresh(a);
      final secondsLeft = a.period - (epoch % a.period);

      next[a.id] = AccountView(account: a, otp: otp, secondsLeft: secondsLeft);
    }
    // set state (only if changed to reduce rebuilds)
    state = Map.unmodifiable(next);
  }

  // allow manual refresh or when accounts change
  Future<void> refreshAccounts() async {
    _accounts = await _authService.getAccounts();
    _tick();
  }

  // lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _ticker?.cancel();
      _ticker = null;
      // optionally clear _secretCache here
    } else if (state == AppLifecycleState.resumed) {
      if (_secretCache.isEmpty) {
        // optionally reload secrets and restart
      }
      _tick();
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  Future<void> addAccount(Account account, String secret) async {
    await _authService.addAccount(account, secret);
    await refreshAccounts();
  }

  Future<void> addAccountFromUri(String uri) async {
    final (account, secret) = _totpService.decode(uri);
    await addAccount(account, secret);
  }
}
