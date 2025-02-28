import 'package:flutter/material.dart';
import '../../presentation/providers/notification_provider.dart';
import '../../presentation/screens/notifications/notification_call_screen.dart';

class NotificationService {
  final NotificationProvider _notificationProvider;
  final GlobalKey<NavigatorState> _navigatorKey;
  bool _isDisposed = false;

  NotificationService(this._notificationProvider, this._navigatorKey) {
    // Listen for changes in the notification provider
    _notificationProvider.addListener(_handleNotificationChange);
  }

  void _handleNotificationChange() {
    if (_isDisposed) return;

    if (_notificationProvider.showNotification && _notificationProvider.activeCall != null) {
      _showNotificationDialog();
    }
  }

  Future<void> _showNotificationDialog() async {
    if (_isDisposed) return;

    // Make sure the navigator is still mounted
    if (_navigatorKey.currentState == null || !_navigatorKey.currentContext!.mounted) {
      return;
    }

    // Check if we can pop to root first (in case multiple dialogs)
    while (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.pop();
    }

    // Show the notification call screen
    try {
      await _navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => NotificationCallScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          // Set this to true to prevent back button functionality
          fullscreenDialog: true,
        ),
      );
    } catch (e) {
      print('Error showing notification dialog: $e');
    }
  }

  // Method to manually trigger a notification for testing
  void triggerTestNotification(Map<String, dynamic> data) {
    if (_isDisposed) return;
    _notificationProvider.handlePushNotification(data);
  }

  // Clean up
  void dispose() {
    _isDisposed = true;
    _notificationProvider.removeListener(_handleNotificationChange);
  }
}