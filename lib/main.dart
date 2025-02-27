import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:holidayscar/providers/wallet_provider.dart';
import 'package:holidayscar/screens/Booking/booking_confirmation.dart';
import 'package:holidayscar/screens/Booking/booking_details_screen.dart';
import 'package:holidayscar/screens/Booking/paymetn_receipt.dart';
import 'package:holidayscar/screens/home.dart';
import 'package:holidayscar/screens/Acccounts/login_screen.dart';
import 'package:holidayscar/screens/Booking/my_booking.dart';
import 'package:holidayscar/screens/Acccounts/profile_screen.dart';
import 'package:holidayscar/screens/Booking/show_result_screeen.dart';
import 'package:holidayscar/screens/Wallet%20System/wallet.dart';
import 'package:holidayscar/services/Notifactions.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:holidayscar/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await NotificationService().init();
  Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';

  // Enable Crashlytics only in release mode
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(analytics: analytics),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const MyApp({super.key, required this.analytics});


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Holidays Car',
          navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
          initialRoute: AppRoutes.splash,
          routes: {
            '/Login': (context) =>  LoginScreen(),
            '/ShowResult': (context) => const ShowResultsScreen(),
            '/PaymentConfirm': (context) => BookingConfirmation(),
            '/BookingDetails': (context) => BookingDetailsScreen(),
            '/MYBooking': (context) => MyBookingsScreen(),
            '/PaymentReceipt': (context) => PaymentReceipt(),
          },
          onGenerateRoute: AppRoutes.generateRoute,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}


class Material3BottomNav extends StatefulWidget {
  const Material3BottomNav({super.key});

  @override
  State<Material3BottomNav> createState() => _Material3BottomNavState();
}

class _Material3BottomNavState extends State<Material3BottomNav> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    MyBookingsScreen(),
    UserProfileScreen(),
    WalletDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: AppTheme.primaryColor,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 500),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}


// class Material3BottomNav extends StatefulWidget {
//   const Material3BottomNav({super.key});
//
//   @override
//   State<Material3BottomNav> createState() => _Material3BottomNavState();
// }
//
// class _Material3BottomNavState extends State<Material3BottomNav> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     MyBookingsScreen(),
//     UserProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoTabScaffold(
//       tabBar: CupertinoTabBar(
//         // activeColor: CupertinoColors.activeBlue,
//         // inactiveColor: CupertinoColors.inactiveGray,
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.car),
//             label: 'Bookings',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       tabBuilder: (context, index) {
//         return CupertinoTabView(
//           builder: (context) {
//             return _screens[index];
//           },
//         );
//       },
//     );
//   }
// }
