import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
//TODO
// import '../screens/home/widgets/home_screen.txt';
// import '../screens/call/call_list_screen.txt';
// import '../screens/call/call_detail_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String callList = '/calls';
  static const String callDetail = '/call/:id';

  // Nested routes
  static const String activeCall = '/home/active_call';
  static const String profile = '/home/profile';
  static const String settings = '/home/settings';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      // case AppRoutes.home:
      //   return MaterialPageRoute(builder: (_) => HomeScreen());

      // case AppRoutes.callList:
      //   return MaterialPageRoute(builder: (_) => CallListScreen());
      //
      // case AppRoutes.callDetail:
      //   final id = settings.arguments as String;
      //   return MaterialPageRoute(
      //     builder: (_) => CallDetailScreen(callId: id),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
