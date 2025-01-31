import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApiService {
  static const String _baseUrl = 'https://holidayscarparking.uk/api';
  Future<bool> login(String email, String password) async {
    const String url = '$_baseUrl/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Check if the response contains the expected keys
        if (responseBody.containsKey('token') && responseBody['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseBody['token']);

          await prefs.setString('user', json.encode(responseBody['user']));
          return true;
        } else {
          // Log an error message if keys are missing
          //print('Error: Missing keys in response body');
          return false;
        }

      } else {
        // Log the response status code for debugging
        //print('Error: Failed to login, status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}