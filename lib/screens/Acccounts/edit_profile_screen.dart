import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/connectivity_provider.dart';
import '../../utils/UiHelper.dart';
import '../../widgets/text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  String? selectedTitle;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData != null) {
      try {
        final decodedUser = json.decode(userData);
        setState(() {
          user = decodedUser;
          emailController.text = user?['email'] ?? '';
          selectedTitle = user?['title'];
          firstNameController.text = user?['first_name'] ?? '';
          lastNameController.text = user?['last_name'] ?? '';
          phoneNumberController.text = user?['phone_number'] ?? '';

        });
      } catch (e) {
        setState(() {
          user = null;
        });
      }
    } else {
    }
  }

  String? token;
  Map<String, dynamic>? user;

  Future<void> _updateUserProfile() async {
    // Show a loading indicator
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CupertinoActivityIndicator(),
          ),
        ),
      ),
    );



    try {
      final response = await http.post(
        Uri.parse('https://holidayscarparking.uk/api/updateUserProfile'),
        body: {
          'user_id': user?['id'].toString(),
          'title': selectedTitle ?? '',
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'phone_number': phoneNumberController.text,
        },
      );

      if (response.statusCode == 200) {
        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        user?['title'] = selectedTitle;
        user?['first_name'] = firstNameController.text;
        user?['last_name'] = lastNameController.text;
        user?['phone_number'] = phoneNumberController.text;
        await prefs.setString('user', json.encode(user));
        Navigator.pop(context);
        // Provide feedback to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    } catch (e) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please check your connection.')),
      );
    } finally {
      // Hide the loading indicator
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611759.jpg?t=st=1737462976~exp=1737466576~hmac=bb7f1ed6b30ebe44da413b5b2cc15fa51ea4e9e3affc6444ac96799a26db1911&w=740'), // Replace with your image asset
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.red),
                      onPressed: () {
                        // Handle image change
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          // labelText: 'Title',
                          prefixIcon: Icon(Icons.person),
                        ),
                        value: selectedTitle,
                        items: ['Mr', 'Ms', 'Mrs', 'Dr']
                            .map((title) => DropdownMenuItem(
                          value: title,
                          child: Text(title),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTitle = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), // Space between the fields
                Expanded(
                  child: CustomTextField(
                    label: 'First Name',
                    hintText: 'First Name',
                    obscureText: false,
                    icon: Icons.person,
                    controller: firstNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Last Name',
              hintText: 'Last Name',
              obscureText: false,
              icon: Icons.person,
              controller: lastNameController,
            ),
            const SizedBox(height: 10),
            // Email Field
            CustomTextField(
              label: 'Email',
              hintText: 'Email',
              obscureText: false,
              icon: Icons.email,
              controller: emailController,
            ),
            // const SizedBox(height: 20),
            const SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                IntlMobileField(
                  decoration: InputDecoration(
                    // labelText: 'Mobile Number',
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent)
                    ),
                  ),
                  controller: phoneNumberController,
                  initialCountryCode: 'GB',
                  disableLengthCounter: true,
                  languageCode: "en",
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile, // Call the update function
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Save Edit Information'),
            ),
          ],
        ),
      ),
    );;
  }


}




