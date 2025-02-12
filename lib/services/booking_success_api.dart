import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> handlePaymentSuccess(String paymentIntentId) async {
  final response = await http.post(
    Uri.parse('https://holidayscarparking.uk/api/booking'),
    body: {
      'referenceNo': 'HCP-04241127820',
      'title': 'Mr',
      'first_name': 'Muhammad',
      'last_name': 'Waqas',
      'email': 'rana_waqas787@yahoo.com',
      'contactno': '03356004040',
      'deprTerminal': '457',
      'deptFlight': 'ASD124',
      'returnTerminal': '457',
      'returnFlight': 'ASD125',
      'model': 'A5',
      'color': 'White',
      'make': 'Audi',
      'registration': 'ASX 075',
      'payment_status': 'success',
      'booking_amount': '60.99',
      'cancelfee': '4.99',
      'smsfee': '1.99',
      'booking_fee': '1.99',
      'discount_amount': '6.52',
      'total_amount': '63.44',
      'intent_id': paymentIntentId,
    },
  );

  if (response.statusCode == 200) {
    // Parse the JSON response
    var jsonResponse = jsonDecode(response.body);
    // Handle success
    ////print('Booking successful: ${jsonResponse['message']}');
  } else {
    // Handle error
    ////print('Failed to book: ${response.reasonPhrase}');
  }
}