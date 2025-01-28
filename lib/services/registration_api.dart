import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationApi {
  Future<Map<String, dynamic>> registerUser({
    required String title, required String firstName, required String lastName, required String phoneNumber, required String email, required String password,
  }) async {
    final response = await http.post(
      Uri.parse('https://holidayscarparking.uk/api/register'),
      body: {
        'title': title, 'first_name': firstName, 'last_name': lastName, 'phone_number': phoneNumber, 'email': email, 'password': password,
      },
    );
    final responseBody = json.decode(response.body);
    return {'statusCode': response.statusCode, 'body': responseBody};
  }

  Future<void> saveUserData(Map<String, dynamic> responseBody) async {
    final prefs = await SharedPreferences.getInstance();
    if (responseBody.containsKey('token') && responseBody['user'] != null) {
      await prefs.setString('token', responseBody['token']);
      await prefs.setString('user', json.encode(responseBody['user']));
    }
  }
}
