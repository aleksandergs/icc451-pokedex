enum FailureType {
  noConnection,
  timeout,
  serverError,
  responseError,
  rateLimited,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(this.type, {this.message});

  final FailureType type;
  final String? message;

  bool get isConnectionIssue =>
      type == FailureType.noConnection || type == FailureType.timeout;

  @override
  String toString() => message ?? type.name;
}
