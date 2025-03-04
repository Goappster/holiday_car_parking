import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holidayscar/routes.dart';

import '../../providers/connectivity_provider.dart';
import '../../services/login_api.dart';
import '../../utils/UiHelper.dart';
import '../../utils/validation_utils.dart';
import '../../widgets/text.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final LoginApiService _apiService = LoginApiService();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Load saved credentials if 'Remember Me' is checked
  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', _rememberMe);
    prefs.setString('email', email);
    prefs.setString('password', password);
  }

  // Clear saved credentials
  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('rememberMe');
    prefs.remove('email');
    prefs.remove('password');
  }

  Future<void> _login(String email, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: AdaptiveLoadingIndicator()),
    );

    try {
      bool success = await _apiService.login(email, password);
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        if (_rememberMe) {
          _saveCredentials(email, password);
        } else {
          _clearCredentials();
        }

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
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred, please try again later.')),
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: screenHeight * 0.10,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomText(text: "Login", fontSizeFactor: 2.0),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Image.asset(
                    'assets/images/pana.png',
                    height: screenHeight * 0.15,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                TextFormField(
                  controller: emailController,
                  autofillHints: [AutofillHints.email],
                  // Autofill hint for email
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: passwordController,
                  autofillHints: [AutofillHints.password],
                  // Autofill hint for password
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons
                            .visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.01),
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
                ElevatedButton(
                  onPressed: () {
                    TextInput
                        .finishAutofillContext(); // Signal autofill context is complete
                    if (_formKey.currentState!.validate()) {
                      _login(emailController.text, passwordController.text);
                    }
                  },
                  child: const Text('Login'),
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Column(
                    children: [
                      CustomText(text: "Don't have an account?",
                          fontSizeFactor: 0.7),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.signup),
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

}