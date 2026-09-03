import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserData(String userData) async {
    await _storage.write(key: 'user_data', value: userData);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: 'user_data');
  }

  Future<void> saveActiveGroupId(String groupId) async {
    await _storage.write(key: AppConstants.activeGroupIdKey, value: groupId);
  }

  Future<String?> getActiveGroupId() async {
    return await _storage.read(key: AppConstants.activeGroupIdKey);
  }

  Future<void> saveActiveGroupName(String groupName) async {
    await _storage.write(key: AppConstants.activeGroupNameKey, value: groupName);
  }

  Future<String?> getActiveGroupName() async {
    return await _storage.read(key: AppConstants.activeGroupNameKey);
  }

  Future<void> saveActiveUserRole(String role) async {
    await _storage.write(key: AppConstants.activeUserRoleKey, value: role);
  }

  Future<String?> getActiveUserRole() async {
    return await _storage.read(key: AppConstants.activeUserRoleKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
