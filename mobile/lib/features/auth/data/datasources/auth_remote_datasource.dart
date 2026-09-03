import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? name, String? phone});
  Future<String?> forgotPassword(String email);
  Future<void> resetPassword({required String token, required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await dio.get(ApiConstants.usersMe);
    return UserModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  Future<UserModel> updateProfile({String? name, String? phone}) async {
    final response = await dio.patch(
      ApiConstants.usersMe,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      },
    );
    return UserModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  Future<String?> forgotPassword(String email) async {
    final response = await dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    // Dev builds echo the raw token so the flow is testable without email.
    return response.data is Map ? response.data['token'] as String? : null;
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await dio.post(
      ApiConstants.resetPassword,
      data: {'token': token, 'newPassword': newPassword},
    );
  }
}
