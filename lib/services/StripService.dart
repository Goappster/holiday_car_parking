import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/services/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import 'Notifactions.dart';

class PaymentService {
  static const String _secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
  // static const String _secretKey = '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';
  final NotificationService _notificationService = NotificationService();
  final DioService _apiService = DioService();

  Future<String?> createOrGetCustomer(String email, String name) async {
    try {
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['id']; // Return customer ID
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

// Function to create payment intent with customer ID
  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency, String customerId) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount) * 100).round().toString(),
        'currency': currency,
        'customer': 'cus_RrF8iSK6b891Rx', // Attach to customer
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

// Function to save card for future payments
  Future<void> saveCardAndMakePayment(
      BuildContext context, String price, String source, Map<String, dynamic> extraData) async {
    try {
      // Generate random user data for testing
      String email = "johndoe123@test.com";
      String name = "John Doe";

      // Create or retrieve the customer
      String? customerId = await createOrGetCustomer(email, name);
      if (customerId == null) throw Exception("Failed to create or get customer");

      // Create payment intent for the customer
      var paymentIntent = await createPaymentIntent(price, 'GBP', 'cus_RrF8iSK6b891Rx');
      if (paymentIntent == null) throw Exception("Failed to create payment intent");

      // Billing details
      BillingDetails billingDetails = BillingDetails(
        name: name,
        email: email,
        phone: "+44 1234 567890",
        address: Address(
          city: "London",
          country: "GB",
          line1: "221B Baker Street",
          line2: "Flat 2",
          postalCode: "NW16XE",
          state: "England",
        ),
      );

      // Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          billingDetails: billingDetails,
          allowsDelayedPaymentMethods: true, // Allows saving cards
        ),
      );

      await displayPaymentSheet(context, price, paymentIntent['id'], source, extraData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

// Function to display payment sheet
  Future<void> displayPaymentSheet(
      BuildContext context, String price, String paymentIntentId, String source, Map<String, dynamic> extraData) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      if (source == 'booking') {
        await sendBooking(context, price, extraData, paymentIntentId);
      } else if (source == 'add_funds') {
        await sendPostRequest(context, paymentIntentId, price, extraData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
    } on StripeException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Cancelled")),
      );
    }
  }
  Future<void> sendBooking(BuildContext context, String price, Map<String, dynamic> bookingDetails, String paymentIntentId) async {
    Map<String, String> bookingData = {
      'referenceNo': bookingDetails['referenceNo'] ?? '',
      'title': bookingDetails['title'] ?? '',
      'first_name': bookingDetails['first_name'] ?? '',
      'last_name': bookingDetails['last_name'] ?? '',
      'email': bookingDetails['email'] ?? '',
      'contactno': bookingDetails['contactno'] ?? '',
      'deprTerminal': bookingDetails['deprTerminal'] ?? '',
      'deptFlight': bookingDetails['deptFlight'] ?? '',
      'returnTerminal': bookingDetails['returnTerminal'] ?? '',
      'returnFlight': bookingDetails['returnFlight'] ?? '',
      'model': bookingDetails['model'] ?? '',
      'color': bookingDetails['color'] ?? '',
      'make': bookingDetails['make'] ?? '',
      'registration': bookingDetails['registration'] ?? '',
      'payment_status': 'wallet',
      'booking_amount': bookingDetails['booking_amount'] ?? '',
      'cancelfee': bookingDetails['cancelfee'] ?? '',
      'smsfee': bookingDetails['smsfee'] ?? '',
      'booking_fee': bookingDetails['booking_fee'] ?? '',
      'discount_amount': bookingDetails['discount_amount'] ?? '',
      'total_amount': price,
      'intent_id': paymentIntentId,
    };

    Response? response = await _apiService.postRequest('booking', bookingData);
    if (response?.statusCode == 200) {
      _notificationService.showNotification(bookingDetails['referenceNo']);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(
          context,
          '/PaymentConfirm',
          arguments: {
            'company': bookingDetails['company'],
            'drop_date': bookingDetails['drop_date'].toString(),
            'drop_time': bookingDetails['drop_time'].toString(),
            'pick_date': bookingDetails['pick_date'].toString(),
            'pick_time': bookingDetails['pick_time'].toString(),
            'totalPrice': price,
            'referenceNo': bookingDetails['referenceNo'].toString(),
          },
        );
      });

    } else {
      print("Booking failed: ${response}");
      throw Exception("Failed to complete booking");
    }
  }

  Future<void> sendPostRequest(BuildContext context, String trxID, String amount, final Map<String, dynamic> extraData,) async {
    Map<String, dynamic> data = {
      'userId': extraData['user_id'],
      'amount': amount,
      'transaction_id': trxID,
      'signature': '40',
    };
    Response? response = await _apiService.postRequest('wallet/add-funds', data);
    if (response != null && response.statusCode == 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Amount has been successfully added to your wallet.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
      // Show Cupertino-style success dialog

    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to add funds: .statusCode}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
      // Show Cupertino-style error message
    }
  }


}


//
// Future<void> saveCardAndMakePayment(BuildContext context, String price, String source, final Map<String, dynamic> extraData) async {
//   try {
//     var paymentIntent = await createPaymentIntent(price, 'GBP');
//
//     if (paymentIntent == null) {
//       throw Exception("Failed to create payment intent");
//     }
//
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: paymentIntent['client_secret'],
//         merchantDisplayName: 'Holiday Car Parking',
//         googlePay: const PaymentSheetGooglePay(
//           testEnv: false,
//           currencyCode: 'GBP',
//           merchantCountryCode: 'GB',
//         ),
//       ),
//     );
//     await displayPaymentSheet(context, price, paymentIntent['id'], source, extraData);
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
//     );
//   }
// }
//