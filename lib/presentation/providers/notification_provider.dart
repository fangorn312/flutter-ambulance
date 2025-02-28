import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/notification_call.dart';
import '../../domain/entities/cancel_reason.dart';
import '../../core/network/api_client.dart';

class NotificationProvider with ChangeNotifier {
  final ApiClient? _apiClient;

  NotificationCall? _activeCall;
  bool _showNotification = false;
  bool _isLoading = false;
  List<CancelReason> _cancelReasons = [];
  String _error = '';

  NotificationProvider([this._apiClient]);

  NotificationCall? get activeCall => _activeCall;
  bool get showNotification => _showNotification;
  bool get isLoading => _isLoading;
  List<CancelReason> get cancelReasons => _cancelReasons;
  String get error => _error;

  // Fetch cancel reasons from the server
  Future<void> fetchCancelReasons() async {
    if (_cancelReasons.isNotEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // final _apiClient = this._apiClient;
      // if (_apiClient != null) {
      //   final response = await _apiClient.get('/api/CancelReasonBrigade/GetAll');
      //
      //   if (response != null && response is List) {
      //     _cancelReasons = response.map((item) => CancelReason(
      //       id: item['id'],
      //       name: item['name'] ?? 'Без названия',
      //       description: item['description'] ?? '',
      //     )).toList();
      //   }
      // } else
      {
        // Fallback to sample data if API client is not available
        _cancelReasons = [
          CancelReason(id: 1, name: 'Бригада занята'),
          CancelReason(id: 2, name: 'Дальняя локация'),
          CancelReason(id: 3, name: 'Технические проблемы'),
          CancelReason(id: 4, name: 'Нет соответствующего специалиста'),
          CancelReason(id: 5, name: 'Другая причина'),
        ];
      }
    } catch (e) {
      _error = 'Ошибка загрузки причин отказа: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // This method would be called when a Firebase message is received
  void handlePushNotification(Map<String, dynamic> message) {
    try {
      final data = message['data'];
      final jsonData = jsonDecode(data['json']);
      final employeeIds = List<int>.from(data['employeeIds'] ?? []);
      final isCancelled = data['cancelCall'] == 'true';

      _activeCall = NotificationCall.fromJson(jsonData, employeeIds, isCancelled);
      _showNotification = true;

      // Automatically fetch cancel reasons when a notification is received
      fetchCancelReasons();

      notifyListeners();
    } catch (e) {
      print('Error parsing push notification: $e');
    }
  }

  Future<void> acceptCall() async {
    if (_activeCall == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final _apiClient = this._apiClient;
      if (_apiClient != null) {
        // Call API to notify that call is accepted
        await _apiClient.get('/api/ZadarmaApi/setAnswerYes',
            queryParameters: {'idCard': _activeCall!.id});
      }

      _showNotification = false;
    } catch (e) {
      _error = 'Ошибка при принятии вызова: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectCall(int reasonId) async {
    if (_activeCall == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // final _apiClient = this._apiClient;
      // if (_apiClient != null) {
      //   // Call API to notify that call is rejected with reason
      //   await _apiClient.get('/api/ZadarmaApi/setAnswerNo',
      //       queryParameters: {
      //         'idCard': _activeCall!.id,
      //         'idCancelReasonBrigade': reasonId
      //       });
      // }

      _showNotification = false;
      _activeCall = null;
    } catch (e) {
      _error = 'Ошибка при отклонении вызова: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNotification() {
    _showNotification = false;
    _activeCall = null;
    notifyListeners();
  }
}