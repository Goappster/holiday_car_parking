
import 'package:flutter/material.dart';
import 'package:holidayscar/routes.dart';
import 'package:holidayscar/services/registration_api.dart';
import '../widgets/text.dart';

class RegistrationService {
  final RegistrationApi _registrationApi = RegistrationApi();

  Future<void> registerUser({
    required String title, required String firstName, required String lastName, required String phoneNumber, required String email, required String password, required BuildContext context,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final result = await _registrationApi.registerUser(
        title: title, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email, password: password,
      );

      Navigator.pop(context);

      if (result['statusCode'] == 200) {
        await _registrationApi.saveUserData(result['body']);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        _showErrorDialog(context, 'Error: ${result['statusCode']} - ${result['body']}');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, 'An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _passwordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final RegistrationService _registrationService = RegistrationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildNameFields(),
              const SizedBox(height: 10),
              _buildLastNameField(),
              const SizedBox(height: 10),
              _buildEmailField(),
              const SizedBox(height: 10),
              _buildPhoneNumberField(),
              const SizedBox(height: 10),
              _buildPasswordField(),
              const SizedBox(height: 20),
              _buildCreateAccountButton(),
              const SizedBox(height: 20),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/Logo.png',
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Create Account',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: 'Title',
            hintText: 'Mr/Ms',
            obscureText: false,
            icon: Icons.person,
            controller: titleController,
          ),
        ),
        const SizedBox(width: 10),
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
    );
  }

  Widget _buildLastNameField() {
    return CustomTextField(
      label: 'Last Name',
      hintText: 'Last Name',
      obscureText: false,
      icon: Icons.email,
      controller: lastNameController,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email',
      hintText: 'Email',
      obscureText: false,
      icon: Icons.email,
      controller: emailController,
    );
  }

  Widget _buildPhoneNumberField() {
    return CustomTextField(
      label: 'Phone Number',
      hintText: 'Phone Number',
      obscureText: false,
      icon: Icons.phone,
      controller: phoneNumberController,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hintText: 'Password',
      obscureText: !_passwordVisible,
      icon: Icons.lock,
      controller: passwordController,
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
    );
  }

  Widget _buildCreateAccountButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () async {
        await _registrationService.registerUser(
          title: titleController.text,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          phoneNumber: phoneNumberController.text,
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
      },
      child: const Text(
        'Create Account',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Column(
        children: [
          Text(
            "Already have an account?",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/Login');
            },
            child:  Text(
              'Login',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
