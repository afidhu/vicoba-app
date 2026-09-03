import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Interceptor that:
/// - Attaches the Bearer JWT token to every request.
/// - Clears storage on 401 responses.
class ApiInterceptor extends Interceptor {
  final SecureStorageService storageService;

  ApiInterceptor({required this.storageService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token is invalid / expired – clear all stored data.
      await storageService.clearAll();
    }
    handler.next(err);
  }
}

