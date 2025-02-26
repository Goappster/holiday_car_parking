import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/services/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  static const String _secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';

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

  Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId, String source, final Map<String, dynamic> extraData,) async {
    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      // Depending on the 'source', make different API calls
      if (source == 'add_funds') {
        // Call API for credit card payment (example)
        await sendPostRequest(context, paymentIntentId, price, extraData);
      } else if (source == 'booking') {
        // Call API for PayPal payment (example)
        // await makePaypalPayment(extraData);
      } else if (source == 'bank_transfer') {
        // Call API for bank transfer payment (example)
        // await makeBankTransferPayment(extraData);
      } else {
        // Default API call if no specific source is matched
        // await makeDefaultPayment(extraData);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Paid successfully")),
      );
    } on StripeException {
      // Show error message if payment is cancelled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Cancelled: ${extraData['user_id']}")),
      );
    }
  }

  final DioService _apiService = DioService();
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
