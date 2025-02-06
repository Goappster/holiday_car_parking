import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/routes.dart';
import 'package:holidayscar/screens/app_setting.dart';
import 'package:holidayscar/screens/vehicle_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}
class _UserProfileScreenState extends State<UserProfileScreen> {
  String? token;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token'); // Can be null or empty
      String? userData = prefs.getString('user');
      if (userData != null) {
        try {
          user = json.decode(userData);
        } catch (e) {
          user = null; // Handle parse error
        }
      }
    });
  }

  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611759.jpg?t=st=1737462976~exp=1737466576~hmac=bb7f1ed6b30ebe44da413b5b2cc15fa51ea4e9e3affc6444ac96799a26db1911&w=740'),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.edit, color: Colors.white, size: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${user?['first_name'] ?? 'No First Name'} ${user?['last_name'] ?? 'No Last Name'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${user?['email'] ?? 'No Email'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.settings, color: Colors.red),
                      title: const Text('Setting'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppSetting(),
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Colors.red),
                      title: const Text('Manage Vehicle'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Colors.red),
                      title: const Text('Bookings Management'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.myBooking);
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.support, color: Colors.red),
                      title: const Text('Customer Support'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.manageTicketScreen);

                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        bool? confirmLogout = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmLogout == true) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                                (route) => false, // This condition removes all previous routes
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVehicleSelected(Vehicle vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
    Navigator.pop(context);
  }
}
