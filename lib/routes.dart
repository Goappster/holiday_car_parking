import 'package:flutter/material.dart';
import 'package:holidayscar/screens/show_result_screeen.dart';
import 'package:holidayscar/screens/splash.dart';
import 'main.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

class AppRoutes {
  static const String login = '/Splash';
  static const String signup = '/signup';
  static const String splash = '/';
  static const String home = '/home';

  static const String showResult = '/showResult';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const CreateAccountScreeen());
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const Material3BottomNav());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen()); // Fallback
    }
  }
}
