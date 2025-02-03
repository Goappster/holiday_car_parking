import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String secretKey;

  PaymentService(this.secretKey);

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
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
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

  Future<void> displayPaymentSheet(BuildContext context, Map<String, dynamic> paymentIntent) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (_) {
      // Handle payment sheet error
    }
  }
}
