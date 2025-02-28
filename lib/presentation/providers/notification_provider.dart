import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/notification_call.dart';

class NotificationProvider with ChangeNotifier {
  NotificationCall? _activeCall;
  bool _showNotification = false;

  NotificationCall? get activeCall => _activeCall;
  bool get showNotification => _showNotification;

  // This method would be called when a Firebase message is received
  void handlePushNotification(Map<String, dynamic> message) {
    try {
      final data = message['data'];
      final jsonData = jsonDecode(data['json']);
      final employeeIds = List<int>.from(data['employeeIds'] ?? []);
      final isCancelled = data['cancelCall'] == 'true';

      _activeCall = NotificationCall.fromJson(jsonData, employeeIds, isCancelled);
      _showNotification = true;
      notifyListeners();
    } catch (e) {
      print('Error parsing push notification: $e');
    }
  }

  void acceptCall() {
    _showNotification = false;
    notifyListeners();
  }

  void rejectCall(int reasonId) {
    // Here you would send the rejection back to the server
    // API call to reject with reasonId

    _showNotification = false;
    _activeCall = null;
    notifyListeners();
  }

  void clearNotification() {
    _showNotification = false;
    _activeCall = null;
    notifyListeners();
  }
}