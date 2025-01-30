import 'dart:convert';

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
      token = prefs.getString('token') ?? ''; // Default to an empty string if null
      String? userData = prefs.getString('user');
      if (userData != null) {
        try {
          user = json.decode(userData);
        } catch (e) {
          print("Failed to parse user data: $e");
          user = null;
        }
      }
    });
  }
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              backgroundImage: NetworkImage('https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611759.jpg?t=st=1737462976~exp=1737466576~hmac=bb7f1ed6b30ebe44da413b5b2cc15fa51ea4e9e3affc6444ac96799a26db1911&w=740'), // Replace with your image asset
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
              '${user?['first_name']} ${user?['last_name']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${user?['email']}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);

              },
              // style: ElevatedButton.styleFrom(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              // ),
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:  ListView(
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
                        onTap: () {},
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                                (route) => false, // This condition removes all previous routes
                          );
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