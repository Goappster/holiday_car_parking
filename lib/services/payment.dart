

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';
  runApp(const Cart());
}


class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Cart")),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Ensure the context is valid before navigation
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentWidget(amount: '100', currency: 'GBP'),
                ),
              );
            },
            child: const Text("Go to Payment"),
          ),
        ),
      ),
    );
  }
}

class PaymentWidget extends StatelessWidget {
  final String amount; final String currency;

  const PaymentWidget({Key? key, required this.amount, required this.currency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Automatically initiate payment when the widget is built
    Future<void> initiatePayment() async {
      try {
        var paymentIntent = await createPaymentIntent(amount, currency);
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            merchantDisplayName: 'Holiday Car Parking',
            googlePay: const PaymentSheetGooglePay(
              testEnv: true,
              currencyCode: 'GBP',
              merchantCountryCode: 'GB',
            ),
          ),
        );
        await displayPaymentSheet(context);
      } catch (e) {
        ////print("Exception: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed")),
        );
      }
    }

    // This will trigger the payment initiation as soon as the widget is built
    Future.delayed(Duration.zero, initiatePayment);
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Screen")),
      body: const Center(
        child: CircularProgressIndicator(),  // Show a loading indicator while processing
      ),
    );
  }

  // Display payment sheet after initialization
  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
    } on StripeException catch (e) {
      ////print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment cancelled")),
      );
    }
  }

  // Create payment intent
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((int.parse(amount)) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      ////print('Error: ${err.toString()}');
      return null;
    }
  }
}
