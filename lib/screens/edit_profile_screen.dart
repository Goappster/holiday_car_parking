import 'package:flutter/material.dart';

import '../widgets/text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  child: CustomTextField(
                    label: 'Title',
                    hintText: 'Mr/Ms',
                    obscureText: false,
                    icon: Icons.person,
                    controller: firstNameController,
                  ),
                ),
                const SizedBox(width: 10), // Space between the fields
                Expanded(
                  child: CustomTextField(
                    label: 'First Name',
                    hintText: 'First Name',
                    obscureText: false,
                    icon: Icons.person,
                    controller: lastNameController,
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
              controller: titleController,
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
            // Phone Number Field
            CustomTextField(
              label: 'Phone Number',
              hintText: 'Phone Number',
              obscureText: false,
              icon: Icons.phone,
              controller: phoneNumberController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle save action
              },
              child: const Text('Save Edit Information'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

}