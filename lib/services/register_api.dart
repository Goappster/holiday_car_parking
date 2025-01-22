import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterApi {
  Future<bool> registerUser({
    required String title,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('https://holidayscarparking.uk/api/register'),
      body: {
        'title': title,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseBody['token']);
      await prefs.setInt('user_id', responseBody['user']['id']);
      await prefs.setString('first_name', responseBody['user']['first_name']);
      await prefs.setString('last_name', responseBody['user']['last_name']);
      await prefs.setString('email', responseBody['user']['email']);
      return true;
    } else {
      print('Registration failed: ${response.body}');
      return false;
    }
  }
}
