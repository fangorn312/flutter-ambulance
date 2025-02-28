import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Ambulance Doctor',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
      debugShowCheckedModeBanner: false,
    );
  }
}