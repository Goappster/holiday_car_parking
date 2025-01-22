import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_mobile_field/intl_mobile_field.dart';

import '../routes.dart';
import '../widgets/text.dart';


class CreateAccountScreeen extends StatefulWidget {
  const CreateAccountScreeen({super.key});

  @override
  State<CreateAccountScreeen> createState() => _CreateAccountScreeenState();
}

class _CreateAccountScreeenState extends State<CreateAccountScreeen> {
  bool _passwordVisible = false;
  bool _rememberMe = false;

  // Add a TextEditingController for each input field
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Future<void> _registerUser() async {
    final response = await http.post(
      Uri.parse('https://holidayscarparking.uk/api/register'),
      body: {
        'title': titleController.text,
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'phone_number': phoneNumberController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'name': nameController.text,
      },
    );

    if (response.statusCode == 200) {
      // Handle successful registration
      print('Registration successful');
    } else {
      // Handle registration error
      print('Registration failed: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Logo.png', // Replace with your logo image path
                      height: 60,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Login Label
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Title Field
              CustomTextField(
                label: 'Title',
                hintText: 'Mr/Ms',
                obscureText: false,
                icon: Icons.person,
                controller: titleController,
              ),
              const SizedBox(height: 10),
              // First Name Field
              CustomTextField(
                label: 'First Name',
                hintText: 'First Name',
                obscureText: false,
                icon: Icons.person,
                controller: firstNameController,
              ),
              const SizedBox(height: 10),
              // Last Name Field
              CustomTextField(
                label: 'Last Name',
                hintText: 'Last Name',
                obscureText: false,
                icon: Icons.person,
                controller: lastNameController,
              ),
              const SizedBox(height: 10),
              // Name Field
              CustomTextField(
                label: 'Name',
                hintText: 'Name',
                obscureText: false,
                icon: Icons.supervised_user_circle_outlined,
                controller: nameController,
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
              const SizedBox(height: 10),
              // Password Field
              CustomTextField(
                label: 'Password',
                hintText: 'Password',
                obscureText: !_passwordVisible,
                icon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                controller: passwordController,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Confirm Passwords',
                obscureText: !_passwordVisible,
                icon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ), controller: passwordController, 
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              // Create Account Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _registerUser,
                child: Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Create Account Link
              Center(
                child: Column(
                  children: [
                    Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/Login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
