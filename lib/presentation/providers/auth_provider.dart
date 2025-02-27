import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    // This will be implemented in a later iteration
    // For now, just simulate a login
    _isAuthenticated = true;
    _currentUser = User(id: '1', username: username, name: 'Doctor Name');
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}