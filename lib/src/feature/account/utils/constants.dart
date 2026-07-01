import 'package:json_annotation/json_annotation.dart';

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

/// Sort fields for ordering accounts on home screen.
///
/// Default is [dateAddedNewest] for backward-compatible behavior.
enum AccountSortField {
  @JsonValue('issuer')
  issuer,
  @JsonValue('label')
  label,
  @JsonValue('date_added_newest')
  dateAddedNewest,
  @JsonValue('date_added_oldest')
  dateAddedOldest,
}

extension AccountSortFieldX on AccountSortField {
  String get displayName {
    switch (this) {
      case AccountSortField.issuer:
        return 'Issuer (A-Z)';
      case AccountSortField.label:
        return 'Account Name (A-Z)';
      case AccountSortField.dateAddedNewest:
        return 'Date Added (Newest)';
      case AccountSortField.dateAddedOldest:
        return 'Date Added (Oldest)';
    }
  }

  String get description {
    switch (this) {
      case AccountSortField.issuer:
        return 'Alphabetical by service or company name';
      case AccountSortField.label:
        return 'Alphabetical by account username';
      case AccountSortField.dateAddedNewest:
        return 'Most recently added accounts first';
      case AccountSortField.dateAddedOldest:
        return 'Earliest added accounts first';
    }
  }
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
