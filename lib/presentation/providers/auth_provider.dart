// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String _errorMessage = '';

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Check authentication status on app start
  Future<void> checkAuth() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    final result = await _authRepository.isLoggedIn();

    result.fold(
            (failure) {
          _status = AuthStatus.unauthenticated;
          _errorMessage = failure.message;
          notifyListeners();
        },
            (isLoggedIn) async {
          if (isLoggedIn) {
            final userResult = await _authRepository.getCurrentUser();

            userResult.fold(
                    (failure) {
                  _status = AuthStatus.unauthenticated;
                  _errorMessage = failure.message;
                  notifyListeners();
                },
                    (user) {
                  _currentUser = user;
                  _status = AuthStatus.authenticated;
                  notifyListeners();
                }
            );
          } else {
            _status = AuthStatus.unauthenticated;
            notifyListeners();
          }
        }
    );
  }

  // Login
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    final result = await _authRepository.login(username, password);

    return result.fold(
            (failure) {
          _status = AuthStatus.error;
          _errorMessage = failure.message;

          if (failure is NetworkFailure) {
            // Handle network failure - maybe try to login offline
            _errorMessage = 'Отсутствует подключение к сети';
          } else if (failure is AuthFailure) {
            _errorMessage = 'Неверный логин или пароль';
          } else {
            _errorMessage = failure.message;
          }

          notifyListeners();
          return false;
        },
            (user) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
    );
  }

  // Logout
  Future<void> logout() async {
    final result = await _authRepository.logout();

    result.fold(
            (failure) {
          _errorMessage = failure.message;
          notifyListeners();
        },
            (_) {
          _status = AuthStatus.unauthenticated;
          _currentUser = null;
          notifyListeners();
        }
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}