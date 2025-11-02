import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'totp_service.g.dart';

class TotpService {
  final StorageService _storageService;

  TotpService({required StorageService storageService})
    : _storageService = storageService;

  Future<String> generateTotp({
    required String secret,
    int digits = AuthConstants.defaultDigits,
    int period = AuthConstants.defaultPeriod,
    String algorithm = AuthConstants.algorithmSHA1,
    DateTime? forTime,
  }) async {
    final List<int> decodedSecret = decodeBase32Secret(secret);

    final now = (forTime ?? DateTime.now().toUtc()).toUtc();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final counter = epochSeconds ~/ period;

    final counterBytes = _int64be(counter);

    // HMAC
    final algo = algorithm.toUpperCase();
    List<int> hmacBytes;
    switch (algo) {
      case AuthConstants.algorithmSHA256:
        hmacBytes = crypto.Hmac(
          crypto.sha256,
          decodedSecret,
        ).convert(counterBytes).bytes;
        break;
      case AuthConstants.algorithmSHA512:
        hmacBytes = crypto.Hmac(
          crypto.sha512,
          decodedSecret,
        ).convert(counterBytes).bytes;
        break;
      case AuthConstants.algorithmSHA1:
      default:
        hmacBytes = crypto.Hmac(
          crypto.sha1,
          decodedSecret,
        ).convert(counterBytes).bytes;
    }

    final codeInt = _dynamicTruncate(hmacBytes) % _pow10(digits);
    return codeInt.toString().padLeft(digits, '0');
  }

  Future<String> generateHotp(String secret, int counter) async {
    throw UnimplementedError(AuthErrorMessages.unimplementedError);
  }

  /// Refreshes the OTP for a given account and returns the new OTP.
  /// This method reads the secret from secure storage and generates a new OTP.
  Future<String> refresh(Account account) async {
    String? encodedSecret = await _storageService.read(
      '${account.issuer}:${account.label}_secret',
      StorageSource.secureStorage,
    );

    final String secret = utf8.decode(base64Decode(encodedSecret ?? ''));

    return await generateTotp(
      secret: secret,
      digits: account.digits,
      period: account.period,
      algorithm: account.algorithm,
    );
  }

  /// Parses a TOTP or HOTP URI and returns a tuple of (SecureEntity, secret).
  /// Throws EntityParseException if the URI is invalid.
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

    String label = rawLabel.contains(':') ? rawLabel.split(':')[0] : rawLabel;
    String accountName = rawLabel.contains(':') ? rawLabel.split(':')[1] : '';

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

    if (label.isEmpty || secret.isEmpty || accountName.isEmpty) {
      throw ParseException(
        code: ErrorCode.invalidCredentials,
        message: AuthErrorMessages.entityParseError,
      );
    } else if (digits <= 0 || period <= 0) {
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
    } else {
      final account = Account(
        label: accountName,
        issuer: issuer.isEmpty ? label : issuer,
        algorithm: algorithm,
        digits: digits,
        period: period,
        type: type,
      );

      return (account, secret);
    }
  }

  /// Deletes an account and its associated secret from storage.
  /// Uses the account's label as the key for deletion.
  ///
  /// Does not throw if the account does not exist.
  Future<void> delete(Account account) async {
    await _storageService.delete(
      account.label,
      StorageSource.sharedPreferences,
    );

    await _storageService.delete(
      '${account.label}_secret',
      StorageSource.secureStorage,
    );
  }

  /// ---- helpers ----

  /// Decodes a Base32-encoded secret into bytes.
  List<int> decodeBase32Secret(String b32) {
    final normalized = b32
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('=', '')
        .toUpperCase();
    return base32.decode(normalized);
  }

  /// dynamic truncation per RFC4226
  int _dynamicTruncate(List<int> hmac) {
    final offset = hmac[hmac.length - 1] & 0x0f;
    final p0 = hmac[offset] & 0x7f;
    final p1 = hmac[offset + 1] & 0xff;
    final p2 = hmac[offset + 2] & 0xff;
    final p3 = hmac[offset + 3] & 0xff;
    return (p0 << 24) | (p1 << 16) | (p2 << 8) | p3;
  }

  /// big-endian 8-byte counter
  List<int> _int64be(int value) {
    final b = ByteData(8);
    b.setInt64(0, value, Endian.big);
    return b.buffer.asUint8List();
  }

  /// integer power of 10
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
  final storageService = ref.read(storageServiceProvider);

  return TotpService(storageService: storageService);
}
