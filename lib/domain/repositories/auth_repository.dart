// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';
import '../../core/network/network_info.dart';
import '../entities/user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
    required NetworkInfo networkInfo,
  })  : _apiClient = apiClient,
        _storageService = storageService,
        _networkInfo = networkInfo;

  // Login with username and password
  Future<Either<Failure, User>> login(String username, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _apiClient.login(username, password);

        // Extract user ID from JWT token (if needed)
        // In this case, we don't need to decode it as per requirements

        // Create user entity
        final user = User(
          id: '1', // This would normally come from the token or API
          username: username,
          name: 'Доктор', // This would normally come from the API
        );

        // Save user to storage
        await _storageService.saveUser(user);

        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    } else {
      // Offline mode - try to authenticate locally if needed
      // For now, just return network failure
      return Left(NetworkFailure('Отсутствует подключение к сети'));
    }
  }

  // Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Get current user
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _storageService.getUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Logout
  Future<Either<Failure, void>> logout() async {
    try {
      await _storageService.clearAll();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}