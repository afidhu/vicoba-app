import 'package:dio/dio.dart';
import '../error/failures.dart';

/// Maps Dio exceptions and other errors to typed [Failure] objects.
class ApiErrorHandler {
  ApiErrorHandler._();

  static Failure handle(Object e) {
    if (e is DioException) {
      return _handleDioException(e);
    }
    return ServerFailure(e.toString());
  }

  static Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timed out. Check your network.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Cannot reach the server. Check your network.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final body = e.response?.data;
        final message = _extractMessage(body) ?? e.message ?? 'Server error.';
        if (statusCode == 401) return AuthFailure(message);
        if (statusCode == 403) return const AuthFailure('Access denied.');
        if (statusCode >= 400 && statusCode < 500) return ValidationFailure(message);
        return ServerFailure(message);
      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');
      default:
        return ServerFailure(e.message ?? 'An unexpected error occurred.');
    }
  }

  static String? _extractMessage(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      final msg = body['message'];
      if (msg is String) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    return null;
  }
}

