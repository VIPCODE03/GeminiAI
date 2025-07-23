class GemException implements Exception {
  final String message;
  final int? statusCode;
  final String? apiErrorReason;

  GemException(this.message, {this.statusCode, this.apiErrorReason});

  @override
  String toString() {
    String result = 'GemException: $message';
    if (statusCode != null) {
      result += '\n(Status Code: $statusCode)';
    }
    if (apiErrorReason != null) {
      result += '\n(API Reason: $apiErrorReason)';
    }
    return result;
  }
}

class NetworkException extends GemException {
  NetworkException()
      : super(
    'A network error occurred. Please check your internet connection.',
    statusCode: null,
    apiErrorReason: 'NETWORK_ERROR',
  );
}

class UnauthorizedException extends GemException {
  UnauthorizedException()
      : super(
    'You are not authorized to access this resource. Please log in again.',
    statusCode: 401,
    apiErrorReason: 'UNAUTHORIZED',
  );
}

class BadRequestException extends GemException {
  BadRequestException()
      : super(
    'The request was invalid. Please check the provided data.',
    statusCode: 400,
    apiErrorReason: 'INVALID_ARGUMENT',
  );
}

class ForbiddenException extends GemException {
  ForbiddenException()
      : super(
    'Access to this resource is forbidden. Your API key might not have the necessary permissions.',
    statusCode: 403,
    apiErrorReason: 'PERMISSION_DENIED',
  );
}

class NotFoundException extends GemException {
  NotFoundException()
      : super(
    'The requested resource could not be found.',
    statusCode: 404,
    apiErrorReason: 'NOT_FOUND',
  );
}

class NotAcceptableException extends GemException {
  NotAcceptableException()
      : super(
    'Insufficient funds to perform the transaction. Or, the server cannot produce a response matching the list of acceptable values defined in the request\'s proactive content negotiation headers.',
    statusCode: 406,
    apiErrorReason: 'NOT_ACCEPTABLE',
  );
}

class TooManyRequestsException extends GemException {
  TooManyRequestsException()
      : super(
    'You have sent too many requests in a given amount of time. Please try again later.',
    statusCode: 429,
    apiErrorReason: 'RESOURCE_EXHAUSTED',
  );
}

class InternalServerErrorException extends GemException {
  InternalServerErrorException()
      : super(
    'An internal server error occurred. Please try again later.',
    statusCode: 500,
    apiErrorReason: 'INTERNAL_SERVER_ERROR',
  );
}

class BadGatewayException extends GemException {
  BadGatewayException()
      : super(
    'Bad Gateway. There was an issue with the server communicating with an upstream server. Please try again later.',
    statusCode: 502,
    apiErrorReason: 'BAD_GATEWAY',
  );
}

class ServiceUnavailableException extends GemException {
  ServiceUnavailableException()
      : super(
    'The service is currently unavailable, possibly due to maintenance. Please try again later.',
    statusCode: 503,
    apiErrorReason: 'SERVICE_UNAVAILABLE',
  );
}