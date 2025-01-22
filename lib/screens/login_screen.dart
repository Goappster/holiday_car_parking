import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes.dart';
import '../widgets/text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  bool _rememberMe = false;

  // Method to handle login
  Future<void> _login(String email, String password) async {
    const String url = 'https://holidayscarparking.uk/api/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        // Handle successful login
        Navigator.pushNamed(context, AppRoutes.Splash);
      } else {
        // Handle login failure
        _showErrorDialog('Login failed. Please check your credentials.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again later.');
    }
  }

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

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
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/pana.png', // Replace with your illustration image path
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),
              // Email Field
              CustomTextField(
                controller: emailController,
                label: 'Email',
                hintText: 'Email',
                obscureText: false,
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              // Password Field
              CustomTextField(
                controller: passwordController,
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
              ),
              const SizedBox(height: 10),
              // Remember Me and Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password functionality
                    },
                    child: const Text('Forget Password?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _login(emailController.text, passwordController.text);
                },
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 20),
              // Create Account Link
              Center(
                child: Column(
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/Signup');
                      },
                      child: const Text(
                        "Create Account",
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
