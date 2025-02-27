// Storage service 
// lib/core/services/storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../../domain/entities/user.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Save JWT token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.keyToken, value: token);
    } catch (e) {
      throw CacheException('Error saving token: ${e.toString()}');
    }
  }

  // Get JWT token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyToken);
    } catch (e) {
      throw CacheException('Error reading token: ${e.toString()}');
    }
  }

  // Delete JWT token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.keyToken);
    } catch (e) {
      throw CacheException('Error deleting token: ${e.toString()}');
    }
  }

  // Save user data
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode({
        'id': user.id,
        'username': user.username,
        'name': user.name,
      });

      await _secureStorage.write(key: AppConstants.keyUser, value: userJson);
    } catch (e) {
      throw CacheException('Error saving user data: ${e.toString()}');
    }
  }

  // Get user data
  Future<User?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: AppConstants.keyUser);

      if (userJson == null || userJson.isEmpty) {
        return null;
      }

      final userData = jsonDecode(userJson);

      return User(
        id: userData['id'],
        username: userData['username'],
        name: userData['name'],
      );
    } catch (e) {
      throw CacheException('Error reading user data: ${e.toString()}');
    }
  }

  // Delete user data
  Future<void> deleteUser() async {
    try {
      await _secureStorage.delete(key: AppConstants.keyUser);
    } catch (e) {
      throw CacheException('Error deleting user data: ${e.toString()}');
    }
  }

  // Clear all storage (for logout)
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException('Error clearing storage: ${e.toString()}');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}