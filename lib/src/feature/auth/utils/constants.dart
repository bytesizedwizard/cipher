abstract class AuthConstants {
  static const String totp = 'totp';
  static const String hotp = 'hotp';

  static const String defaultAlgorithm = 'SHA1';
  static const int defaultDigits = 6;
  static const int defaultPeriod = 30;

  static const String uriScheme = 'otpauth';

  static const String algorithmSHA1 = 'SHA1';
  static const String algorithmSHA256 = 'SHA256';
  static const String algorithmSHA512 = 'SHA512';
}

abstract class AuthErrorMessages {
  static const String networkError =
      'Network error occurred. Please try again.';
  static const String invalidCredentials = 'Invalid credentials provided.';
  static const String notFound = "The requested resource was not found.";
  static const String accountDisabled = 'User account is disabled.';
  static const String tooManyRequests =
      'Too many requests. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String entityParseError =
      'Failed to parse authentication entity.';

  static const String unimplementedError =
      "This feature is not yet implemented.";
}
