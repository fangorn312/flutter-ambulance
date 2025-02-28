import 'package:flutter/material.dart';
import '../../presentation/providers/notification_provider.dart';
import '../../presentation/screens/notifications/notification_call_screen.dart';

class NotificationService {
  final NotificationProvider _notificationProvider;
  final GlobalKey<NavigatorState> _navigatorKey;

  NotificationService(this._notificationProvider, this._navigatorKey) {
    // Listen for changes in the notification provider
    _notificationProvider.addListener(_handleNotificationChange);
  }

  void _handleNotificationChange() {
    if (_notificationProvider.showNotification && _notificationProvider.activeCall != null) {
      _showNotificationDialog();
    }
  }

  Future<void> _showNotificationDialog() async {
    // Check if we can pop to root first (in case multiple dialogs)
    while (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.pop();
    }

    // Show the notification call screen
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
  }

  // Method to manually trigger a notification for testing
  void triggerTestNotification(Map<String, dynamic> data) {
    _notificationProvider.handlePushNotification(data);
  }

  // Clean up
  void dispose() {
    _notificationProvider.removeListener(_handleNotificationChange);
  }
}