import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

class BookingApi {
  static const String baseUrl = 'https://holidayscarparking.uk/api/saveIncompleteBooking';

  Future<void> saveIncompleteBooking({
    required  title,
    required  firstName,
    required lastName,
    required email,
    required contactNo,
    required  parkingType,
    required  dropDate,
    required  dropTime,
    required  pickDate,
    required  pickTime,
    required  totalDays,
    required  airportId,
    required productId,
    required productCode,
    required  parkApi,
    required  bookingAmount,
    required  bookingFee,
    required   discountAmount,
    required  totalAmount,
    required  promo,
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
      print(response.body);
      throw Exception('Failed to save booking');
    }
  }
}
