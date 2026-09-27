import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef ClipboardWriter = Future<void> Function(String value);
typedef ClipboardTimerFactory =
    Timer Function(Duration duration, void Function() callback);

class SecureClipboardService {
  SecureClipboardService({
    ClipboardWriter? writer,
    ClipboardTimerFactory? timerFactory,
  }) : _writer = writer ?? _writeSystemClipboard,
       _timerFactory =
           timerFactory ?? ((duration, callback) => Timer(duration, callback));

  final ClipboardWriter _writer;
  final ClipboardTimerFactory _timerFactory;
  Timer? _clearTimer;
  int _copyGeneration = 0;

  Future<void> copy(String value, {required int timeoutMilliseconds}) async {
    await _writer(value);

    _clearTimer?.cancel();
    final generation = ++_copyGeneration;
    if (timeoutMilliseconds <= 0) {
      return;
    }

    _clearTimer = _timerFactory(
      Duration(milliseconds: timeoutMilliseconds),
      () {
        if (generation != _copyGeneration) {
          return;
        }
        unawaited(clear());
      },
    );
  }

  Future<void> clear() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    _copyGeneration++;
    await _writer('');
  }

  void dispose() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }

  static Future<void> _writeSystemClipboard(String value) {
    return Clipboard.setData(ClipboardData(text: value));
  }
}

final secureClipboardServiceProvider = Provider<SecureClipboardService>((ref) {
  final service = SecureClipboardService();
  ref.onDispose(service.dispose);
  return service;
});
