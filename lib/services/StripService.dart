import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/services/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import 'Notifactions.dart';

class PaymentService {
  static const String _secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
  final NotificationService _notificationService = NotificationService();
  final DioService _apiService = DioService();
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount) * 100).round().toString(),
        'currency': currency,
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

  Future<void> saveCardAndMakePayment(BuildContext context, String price, String source, final Map<String, dynamic> extraData) async {
    try {
      var paymentIntent = await createPaymentIntent(price, 'GBP');

      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          googlePay: const PaymentSheetGooglePay(
            testEnv: false,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
        ),
      );
      await displayPaymentSheet(context, price, paymentIntent['id'], source, extraData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId, String source, Map<String, dynamic> extraData,) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      if (source == 'booking') {
        // sendBooking(context, price, extraData, paymentIntentId);
      } else if (source == 'addFunds') { // Fix duplicate condition
        // await sendPostRequest(context, paymentIntentId, price, extraData);
      } else if (source == 'bank_transfer') {
        // await makeBankTransferPayment(extraData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Navigator.pushNamed(
      //     context,
      //     '/PaymentConfirm',
      //     arguments: {
      //       'company': extraData['company'],
      //       'drop_date': extraData['drop_date'].toString(),
      //       'drop_time': extraData['drop_time'].toString(),
      //       'pick_date': extraData['pick_date'].toString(),
      //       'pick_time': extraData['pick_time'].toString(),
      //       'totalPrice': price,
      //       'referenceNo': extraData['referenceNo'].toString(),
      //     },
      //   );
      // });
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
      // Show Cupertino-style success dialog
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
    } else {
      // Show Cupertino-style error message
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
    }
  }


}
