import 'package:flutter/material.dart';

enum ConnectionStatus { online, offline }
enum SyncStatus { synced, syncing, failed }

class AppProvider with ChangeNotifier {
  // Connection state
  ConnectionStatus _connectionStatus = ConnectionStatus.online;
  ConnectionStatus get connectionStatus => _connectionStatus;

  // Sync state
  SyncStatus _syncStatus = SyncStatus.synced;
  SyncStatus get syncStatus => _syncStatus;

  // App state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String _error = '';
  String get error => _error;

  // Methods
  void setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  void setSyncStatus(SyncStatus status) {
    _syncStatus = status;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setError(String value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}