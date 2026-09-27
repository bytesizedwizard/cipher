import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'totp_service.g.dart';

class TotpService {
  TotpService({required AccountStorageService accountStorageService})
    : _accountStorageService = accountStorageService;

  final AccountStorageService _accountStorageService;

  Future<String> generateTotp({
    required String secret,
    int digits = AuthConstants.defaultDigits,
    int period = AuthConstants.defaultPeriod,
    String algorithm = AuthConstants.algorithmSHA1,
    DateTime? forTime,
  }) async {
    final now = (forTime ?? DateTime.now().toUtc()).toUtc();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final counter = epochSeconds ~/ period;

    return generateHotp(secret, counter, digits: digits, algorithm: algorithm);
  }

  Future<String> generateHotp(
    String secret,
    int counter, {
    int digits = AuthConstants.defaultDigits,
    String algorithm = AuthConstants.defaultAlgorithm,
  }) async {
    if (counter < 0 || digits <= 0) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    }

    final decodedSecret = decodeBase32Secret(secret);
    final hmacBytes = _hmac(decodedSecret, _int64be(counter), algorithm);
    final codeInt = _dynamicTruncate(hmacBytes) % _pow10(digits);
    return codeInt.toString().padLeft(digits, '0');
  }

  Future<String> refresh(Account account) async {
    final secret = await _accountStorageService.readSecret(account);

    if (account.type == AuthConstants.hotp) {
      return generateHotp(
        secret,
        account.counter,
        digits: account.digits,
        algorithm: account.algorithm,
      );
    }
    return generateTotp(
      secret: secret,
      digits: account.digits,
      period: account.period,
      algorithm: account.algorithm,
    );
  }

  (Account, String) decode(String uri) {
    Uri parsed = Uri.parse(uri);

    if (parsed.scheme != AuthConstants.uriScheme) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    } else if (parsed.host != AuthConstants.totp &&
        parsed.host != AuthConstants.hotp) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    }

    String rawLabel = parsed.pathSegments.isNotEmpty
        ? parsed.pathSegments[0]
        : '';

    String label = rawLabel.contains(':') ? rawLabel.split(':')[0] : '';
    String accountName = rawLabel.contains(':')
        ? rawLabel.split(':')[1]
        : rawLabel;

    String secret = parsed.queryParameters['secret'] ?? '';
    String issuer = parsed.queryParameters['issuer'] ?? '';
    String algorithm =
        parsed.queryParameters['algorithm'] ?? AuthConstants.defaultAlgorithm;
    int digits =
        int.tryParse(parsed.queryParameters['digits'] ?? '') ??
        AuthConstants.defaultDigits;
    int period =
        int.tryParse(parsed.queryParameters['period'] ?? '') ??
        AuthConstants.defaultPeriod;
    String type = parsed.host;
    int counter = 0;

    if (secret.isEmpty || accountName.isEmpty) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    }

    try {
      decodeBase32Secret(secret);
    } catch (_) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    }

    if (digits <= 0 || period <= 0) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    } else if (type != AuthConstants.totp && type != AuthConstants.hotp) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    } else if (algorithm != AuthConstants.algorithmSHA1 &&
        algorithm != AuthConstants.algorithmSHA256 &&
        algorithm != AuthConstants.algorithmSHA512) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    } else if (type == AuthConstants.hotp) {
      final parsedCounter = int.tryParse(
        parsed.queryParameters['counter'] ?? '',
      );
      if (parsedCounter == null || parsedCounter < 0) {
        throw ParseException(
          code: ErrorCode.invalidCredentials,
          message: AuthErrorMessages.entityParseError,
        );
      }
      counter = parsedCounter;
    }

    final account = Account(
      label: accountName,
      issuer: issuer.isEmpty ? label : issuer,
      algorithm: algorithm,
      digits: digits,
      period: period,
      type: type,
      counter: counter,
    );

    return (account, secret);
  }

  Future<void> delete(Account account) async {
    await _accountStorageService.delete(account);
  }

  List<int> decodeBase32Secret(String b32) {
    final normalized = b32
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('=', '')
        .toUpperCase();
    return base32.decode(normalized);
  }

  int _dynamicTruncate(List<int> hmac) {
    final offset = hmac[hmac.length - 1] & 0x0f;
    final p0 = hmac[offset] & 0x7f;
    final p1 = hmac[offset + 1] & 0xff;
    final p2 = hmac[offset + 2] & 0xff;
    final p3 = hmac[offset + 3] & 0xff;
    return (p0 << 24) | (p1 << 16) | (p2 << 8) | p3;
  }

  List<int> _hmac(List<int> secret, List<int> counter, String algorithm) {
    switch (algorithm.toUpperCase()) {
      case AuthConstants.algorithmSHA256:
        return crypto.Hmac(crypto.sha256, secret).convert(counter).bytes;
      case AuthConstants.algorithmSHA512:
        return crypto.Hmac(crypto.sha512, secret).convert(counter).bytes;
      case AuthConstants.algorithmSHA1:
        return crypto.Hmac(crypto.sha1, secret).convert(counter).bytes;
      default:
        throw ParseException(
          code: ErrorCode.invalidCredentials,
          message: AuthErrorMessages.entityParseError,
        );
    }
  }

  List<int> _int64be(int value) {
    final b = ByteData(8);
    b.setInt64(0, value, Endian.big);
    return b.buffer.asUint8List();
  }

  int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}

@Riverpod(keepAlive: true)
TotpService totpService(Ref ref) {
  final accountStorageService = ref.read(accountStorageServiceProvider);

  return TotpService(accountStorageService: accountStorageService);
}
