import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => NotificationProvider(di.sl())),
      ],
      child: MyApp(),
    ),
  );
}