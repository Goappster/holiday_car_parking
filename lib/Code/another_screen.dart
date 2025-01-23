import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnotherScreen extends StatefulWidget {
  @override
  _AnotherScreenState createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen> {
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
      token = prefs.getString('token');
     String? userData = prefs.getString('user');
      if (userData != null) {
        user = json.decode(userData);
         firstName = user?['first_name'];
         lastName = user?['last_name'];
      }
    });
  }

  late String firstName;
  late String lastName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Another Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(firstName),
            Text('Token: $token'),
            if (user != null) ...[
              Text('User ID: ${user!['id']}'),
              Text('Last Name: ${user!['last_name']}'),
              Text('Email: ${user!['email']}'),
            ],
          ],
        ),
      ),
    );
  }
}