enum ErrorCode {
  networkError(1001),
  invalidCredentials(1002),
  notFound(1003),
  userDisabled(1004),
  tooManyRequests(1005),
  unknownError(9999);

  final int code;
  const ErrorCode(this.code);
}

enum AccountStorageIssueCode {
  invalidRecord,
  invalidSecret,
  missingSecret,
  verificationFailed,
  migrationFailed,
  readFailed,
  writeFailed,
  deleteFailed,
}

class AccountStorageIssue implements Exception {
  AccountStorageIssue({
    required this.code,
    required this.operation,
    this.accountId,
  });

  final AccountStorageIssueCode code;
  final String operation;
  final String? accountId;

  String get message {
    final target = accountId == null ? '' : ' for account $accountId';
    switch (code) {
      case AccountStorageIssueCode.invalidRecord:
        return 'Stored account record is invalid$target.';
      case AccountStorageIssueCode.invalidSecret:
        return 'Account secret is invalid$target.';
      case AccountStorageIssueCode.missingSecret:
        return 'Account secret is missing$target.';
      case AccountStorageIssueCode.verificationFailed:
        return 'Account storage verification failed$target.';
      case AccountStorageIssueCode.migrationFailed:
        return 'Account migration failed$target.';
      case AccountStorageIssueCode.readFailed:
        return 'Unable to read accounts.';
      case AccountStorageIssueCode.writeFailed:
        return 'Unable to save account$target.';
      case AccountStorageIssueCode.deleteFailed:
        return 'Unable to delete account$target.';
    }
  }

  @override
  String toString() => 'AccountStorageIssue($operation): $message';
}

class ParseException implements Exception {
  final ErrorCode code;
  final String message;

  ParseException({required this.code, required this.message});

  @override
  String toString() => 'ParseException $code: $message';
}

class FetchException implements Exception {
  final ErrorCode code;
  final String message;

  FetchException({required this.code, required this.message});

  @override
  String toString() => 'FetchException $code: $message';
}
