import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingApi {
  static const String baseUrl = 'https://holidayscarparking.uk/api/saveIncompleteBooking';

  Future<void> saveIncompleteBooking({
    required String title,
    required String firstName,
    required String lastName,
    required String email,
    required String contactNo,
    required String parkingType,
    required String dropDate,
    required String dropTime,
    required String pickDate,
    required String pickTime,
    required int totalDays,
    required int airportId,
    required int productId,
    required String productCode,
    required String parkApi,
    required double bookingAmount,
    required double bookingFee,
    required double discountAmount,
    required double totalAmount,
    required String promo,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'contactno': contactNo,
        'parking_type': parkingType,
        'drop_date': dropDate,
        'drop_time': dropTime,
        'pick_date': pickDate,
        'pick_time': pickTime,
        'total_days': totalDays,
        'airport_id': airportId,
        'product_id': productId,
        'product_code': productCode,
        'park_api': parkApi,
        'booking_amount': bookingAmount,
        'booking_fee': bookingFee,
        'discount_amount': discountAmount,
        'total_amount': totalAmount,
        'promo': promo,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save booking');
    }
  }
}
