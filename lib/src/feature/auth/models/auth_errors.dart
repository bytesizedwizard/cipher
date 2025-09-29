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
