import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/routes/app_router.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  NotificationService? _notificationService;
  FirebaseService? _firebaseService;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize services if not already initialized
    if (!_initialized) {
      _initializeServices();
      _initialized = true;
    }
  }

  void _initializeServices() {
    // Get the NotificationProvider from the context
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    // Initialize notification service
    _notificationService = NotificationService(notificationProvider, _navigatorKey);

    // Initialize Firebase service
    _firebaseService = FirebaseService(notificationProvider);
    _firebaseService!.initialize().then((_) {
      // Subscribe to the appropriate topic after initialization
      //_firebaseService!.subscribeToTopic('topic1');
    });
  }

  @override
  void dispose() {
    // Clean up services
    _notificationService?.dispose();
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
      initialRoute: authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
      debugShowCheckedModeBanner: false,
    );
  }
}