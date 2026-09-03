import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final String token = response['accessToken'];
      final UserModel user = UserModel.fromJson(response['user']);

      await storageService.saveToken(token);
      await storageService.saveUserData(jsonEncode(user.toJson()));

      return Right(user);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> registerAndLogin({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      final String token = response['accessToken'];
      final UserModel user = UserModel.fromJson(response['user']);

      await storageService.saveToken(token);
      await storageService.saveUserData(jsonEncode(user.toJson()));

      return Right(user);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      await storageService.saveUserData(jsonEncode(user.toJson()));
      return Right(user);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({String? name, String? phone}) async {
    try {
      final user = await remoteDataSource.updateProfile(name: name, phone: phone);
      await storageService.saveUserData(jsonEncode(user.toJson()));
      return Right(user);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, String?>> forgotPassword(String email) async {
    try {
      return Right(await remoteDataSource.forgotPassword(email));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(token: token, newPassword: newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await storageService.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
