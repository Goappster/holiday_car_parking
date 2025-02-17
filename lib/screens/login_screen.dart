import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/routes.dart';

import '../services/login_api.dart';
import '../utils/UiHelper.dart';
import '../utils/validation_utils.dart';
import '../widgets/text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  bool _rememberMe = false;

  final LoginApiService _apiService = LoginApiService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(String email, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: AdaptiveLoadingIndicator()),
    );

    bool success = await _apiService.login(email, password);
    Navigator.of(context).pop(); // Close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User signed in successfully!')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02, ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.05), // Responsive spacing
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: screenHeight * 0.10, // Scales based on screen height
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // Login Text
                CustomText(text: "Login", fontSizeFactor: 2.0),
                SizedBox(height: screenHeight * 0.02),
                // Illustration Image
                Center(
                  child: Image.asset(
                    'assets/images/pana.png',
                    height: screenHeight * 0.15,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  obscureText: false,
                  icon: Icons.email,
                  controller: _emailController,
                  validator: validateEmail,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: !_passwordVisible,
                  icon: Icons.lock,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off,),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  validator: validatePassword,
                ),
                SizedBox(height: screenHeight * 0.01),
                // Remember Me & Forgot Password
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
                        Navigator.pushNamed(context, AppRoutes.forgetPass);
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Login Button
                CustomButton(
                  text: 'Login',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _login(_emailController.text, _passwordController.text);
                    }
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                // Create Account Section
                Center(
                  child: Column(
                    children: [
                      CustomText(text: "Don't have an account?", fontSizeFactor: 0.7),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                        child: CustomText(
                          text: "Create Account",
                          fontSizeFactor: 0.5,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
