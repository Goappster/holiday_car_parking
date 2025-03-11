import 'package:flutter/material.dart';
import 'package:holidayscar/routes.dart';
import 'package:holidayscar/services/registration_api.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:intl_mobile_field/mobile_number.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../utils/UiHelper.dart';
import '../../widgets/text.dart';

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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final RegistrationService _registrationService = RegistrationService();

  final _formKey = GlobalKey<FormState>();

  String? selectedTitle;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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

    late FocusNode _focusNode;
    bool _isFocused = false;

    @override
    void initState() {
      super.initState();
      _focusNode = FocusNode();
      _focusNode.addListener(() {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      });
    }

    @override
    void dispose() {
      _focusNode.dispose();
      super.dispose();
    }


    return Row(
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
                  prefixIcon: Icon(Icons.person,
                    color: _isFocused ? Colors.red : Colors.grey,
                  ),
                ),
                hint: Text("Select title"),
                style: Theme.of(context).textTheme.labelLarge,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a title';
                  }
                  return null;
                },
              ),
            ],
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your last name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email',
      hintText: 'Email',
      obscureText: false,
      icon: Icons.email,
      controller: emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^\S+@\S+\.\S+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
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
          controller: phoneNumberController ,
          initialCountryCode: 'GB',
          // disableLengthCounter: true,
          languageCode: "en",
          validator: (MobileNumber? value) {
            if (value == null || value.number.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.number)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },

        )
      ],
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
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
        if (_formKey.currentState!.validate()) {
          await _registrationService.registerUser(
            title: selectedTitle!,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            phoneNumber: phoneNumberController.text.toString(),
            email: emailController.text,
            password: passwordController.text,
            context: context,
          );
        }
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



