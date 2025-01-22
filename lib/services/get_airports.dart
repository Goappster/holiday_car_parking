import 'dart:convert';
import 'package:http/http.dart' as http;

class GetAirports {
  static const String _baseUrl = 'https://holidayscarparking.uk/api/';

  static Future<List<Map<String, dynamic>>> fetchAirports() async {
    final response = await http.get(Uri.parse('${_baseUrl}airportsList'));

    if (response.statusCode == 200) {
      final List airports = json.decode(response.body)['airports'];
      return airports.map<Map<String, dynamic>>((airport) {
        return {
          'id': airport['id'],
          'name': airport['name'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load airports');
    }
  }
}
