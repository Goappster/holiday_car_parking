import 'package:flutter/material.dart';
import 'package:holidayscar/screens/Acccounts/edit_profile_screen.dart';
import 'package:holidayscar/screens/Acccounts/forget_pass.dart';
import 'package:holidayscar/screens/getsupport_ticket.dart';
import 'package:holidayscar/screens/Booking/my_booking.dart';
import 'package:holidayscar/screens/Acccounts/splash.dart';
import 'package:holidayscar/screens/support_ticket.dart';
import 'package:holidayscar/screens/vehicle_management.dart';
import 'main.dart';
import 'screens/Acccounts/login_screen.dart';
import 'screens/Acccounts/signup_screen.dart';

class AppRoutes {
  static const String login = '/Login';
  static const String signup = '/signup';
  static const String splash = '/';
  static const String home = '/home';

  static const String showResult = '/showResult';
  static const String myBooking = '/myBooking';
  static const String editProfile = '/editProfile';
  static const String forgetPass = '/forgetPass';
  static const String createSupportTicket = '/supportTicket';
  static const String manageTicketScreen = '/manageTicketScreen';
  static const String vehicleManagement = '/vehicleManagement';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const Material3BottomNav());
      case myBooking:
        return MaterialPageRoute(builder: (_) =>  MyBookingsScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) =>  const EditProfileScreen());
      case forgetPass:
        return MaterialPageRoute(builder: (_) =>  ForgotPasswordScreen());
      case createSupportTicket:
        return MaterialPageRoute(builder: (_) =>  SupportTicketForm());
      case manageTicketScreen:
        return MaterialPageRoute(builder: (_) =>  SupportTicketScreen());
      case vehicleManagement:
        return MaterialPageRoute(builder: (_) =>  VehicleManagementScreen());
      default:
        return MaterialPageRoute(builder: (_) =>  LoginScreen()); // Fallback
    }
  }
}
