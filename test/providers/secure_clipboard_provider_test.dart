import 'dart:async';

import 'package:cipher/src/providers/secure_clipboard_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an older cleanup callback cannot clear a newer copy', () async {
    final values = <String>[];
    final callbacks = <void Function()>[];
    final service = SecureClipboardService(
      writer: (value) async => values.add(value),
      timerFactory: (duration, callback) {
        callbacks.add(callback);
        return Timer(const Duration(hours: 1), () {});
      },
    );
    addTearDown(service.dispose);

    await service.copy('111111', timeoutMilliseconds: 500);
    await service.copy('222222', timeoutMilliseconds: 500);

    callbacks[0]();
    await Future<void>.delayed(Duration.zero);
    expect(values, ['111111', '222222']);

    callbacks[1]();
    await Future<void>.delayed(Duration.zero);
    expect(values, ['111111', '222222', '']);
  });

  test(
    'cleanup clears the current value after the active callback runs',
    () async {
      final values = <String>[];
      final callbacks = <void Function()>[];
      final service = SecureClipboardService(
        writer: (value) async => values.add(value),
        timerFactory: (duration, callback) {
          callbacks.add(callback);
          return Timer(const Duration(hours: 1), () {});
        },
      );
      addTearDown(service.dispose);

      await service.copy('123456', timeoutMilliseconds: 500);
      callbacks.single();
      await Future<void>.delayed(Duration.zero);

      expect(values, ['123456', '']);
    },
  );

  test('zero timeout leaves the clipboard until an explicit clear', () async {
    final values = <String>[];
    final service = SecureClipboardService(
      writer: (value) async => values.add(value),
      timerFactory: (duration, callback) {
        fail('A timer must not be scheduled for a zero timeout.');
      },
    );
    addTearDown(service.dispose);

    await service.copy('654321', timeoutMilliseconds: 0);
    expect(values, ['654321']);

    await service.clear();
    expect(values, ['654321', '']);
  });
}
