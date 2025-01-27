import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:holidayscar/screens/booking.dart';
import 'package:holidayscar/screens/booking_confirmation.dart';
import 'package:holidayscar/screens/booking_details_screen.dart';
import 'package:holidayscar/screens/home.dart';
import 'package:holidayscar/screens/login_screen.dart';
import 'package:holidayscar/screens/my_booking.dart';
import 'package:holidayscar/screens/profile_screen.dart';
import 'package:holidayscar/screens/show_result_screeen.dart';
import 'package:holidayscar/screens/vehicle_management.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/providers/theme_provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:holidayscar/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Holidays Car',
          initialRoute: AppRoutes.splash,
          routes: {
            // '/': (context) => const LoginScreen(),
            // '/Signup': (context) => const CreateAccountScreeen(),
            '/Login': (context) => const LoginScreen(),
            '/ShowResult': (context) => const ShowResultsScreen(),
            // '/Booking': (context) => BookingScreen(),
            '/PaymentConfirm': (context) => BookingConfirmation(),
            '/BookingDetails': (context) => BookingDetailsScreen(),
            '/MYBooking': (context) => MyBookingsScreen(),


          },
          onGenerateRoute: AppRoutes.generateRoute,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
    // const CartScreen(),
   // BookingScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _navBarItems,
      ),
    );
  }
}

const _navBarItems = [
  NavigationDestination(
    icon: Icon(MingCute.home_4_line),
    selectedIcon: Icon(MingCute.home_4_fill),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(MingCute.car_2_line),
    selectedIcon: Icon(MingCute.car_2_fill),
    label: 'Bookings',
  ),
  // NavigationDestination(
  //   icon: Icon(Icons.shopping_bag_outlined),
  //   selectedIcon: Icon(Icons.shopping_bag),
  //   label: 'Cart',
  // ),
  NavigationDestination(
    icon: Icon(Icons.person_outline_rounded),
    selectedIcon: Icon(Icons.person_rounded),
    label: 'Profile',
  ),
];



class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Bookmarks Screen', style: Theme
          .of(context)
          .textTheme
          .bodyLarge),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Screen', style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
