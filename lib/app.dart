import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();

    // Initialize services after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(
          context, listen: false);

      // Initialize notification service
      _notificationService =
          NotificationService(notificationProvider, _navigatorKey);

      // Initialize Firebase service
      final firebaseService = FirebaseService(notificationProvider);
      firebaseService.initialize().then((_) {
        // Subscribe to the appropriate topic after initialization
        //firebaseService.subscribeToTopic('topic1');

        // For testing - uncomment to simulate a notification
        // _simulateNotification();
      });
    });
  }

  // For testing purposes only
  void _simulateNotification() {
    Future.delayed(Duration(seconds: 5), () {
      final Map<String, dynamic> testNotification = {
        'data': {
          'json': '{"id":123,"idOccassionNavName":"Температура","isUnknownPatient":false,"addressFull":"Ленина 12","fullName":"Иванов Иван","phoneCaller":"778123","phonePatient":"771333","strbrigadeSetupDate":"2025-02-20 08:00:00","brigadeId":1}',
          'employeeIds': [123, 45, 67],
          'cancelCall': 'false'
        },
        'topic': 'topic1'
      };

      _notificationService.triggerTestNotification(testNotification);
    });
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Ambulance Doctor',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: authProvider.isAuthenticated ? AppRoutes.home : AppRoutes
          .login,
      debugShowCheckedModeBanner: false,
    );
  }
}