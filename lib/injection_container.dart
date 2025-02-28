// lib/injection_container.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/services/storage_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/app_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Providers
  sl.registerFactory(
        () => AuthProvider(
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
        () => AppProvider(),
  );

  // Repositories
  sl.registerLazySingleton(
        () => AuthRepository(
      apiClient: sl(),
      storageService: sl(),
      networkInfo: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton(
        () => ApiClient(sl()),
  );

  sl.registerLazySingleton(
        () => StorageService(
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton(
        () => NetworkInfo(sl()),
  );

  // External
  sl.registerLazySingleton(
        () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton(
        () => Connectivity(),
  );

  // Check if ApiClient is already registered in the injection container.
// If not, add this code to the init() function in injection_container.dart:

// Register ApiClient
//   sl.registerLazySingleton(
//         () => ApiClient(sl()),
//   );
}