import 'package:flutter/material.dart';
import 'package:holidayscar/screens/splash.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

class AppRoutes {
  static const String login = '/Splash';
  static const String signup = '/signup';
  static const String Splash = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => CreateAccountScreeen());
      case Splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen()); // Fallback
    }
  }
}
