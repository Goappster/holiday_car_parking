import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>> fetchQuotes({
    required String airportId,
    required String dropDate,
    required String dropTime,
    required String pickDate,
    required String pickTime,
    required String promo,
  }) async {
    final url = Uri.parse("https://holidayscarparking.uk/api/getQuote");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "airport_id": airportId,
        "drop_date": dropDate,
        "drop_time": dropTime,
        "pick_date": pickDate,
        "pick_time": pickTime,
        "promo": promo,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Ensure we return a Map<String, dynamic> from the response
      return jsonResponse; // Return the complete response as a Map
    } else {
      throw Exception("Failed to fetch data: ${response.body}");
    }
  }
}
