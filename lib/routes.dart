import 'package:flutter/material.dart';
import 'package:holidayscar/screens/edit_profile_screen.dart';
import 'package:holidayscar/screens/my_booking.dart';
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
  static const String myBooking = '/myBooking';
  static const String editProfile = '/editProfile';

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
      case myBooking:
        return MaterialPageRoute(builder: (_) =>  MyBookingsScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) =>  const EditProfileScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen()); // Fallback
    }
  }
}
