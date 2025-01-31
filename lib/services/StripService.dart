import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stripe Payment',
      home: StripePaymentScreen(),
    );
  }
}

class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({super.key});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Save Card & Make Payment'),
          onPressed: () async {
            await saveCardAndMakePayment();
          },
        ),
      ),
    );
  }

  Future<void> saveCardAndMakePayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'GBP');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
          // customerId: '1',  // If you have a customer
        ),
      );
      await displayPaymentSheet();

    } catch (e) {
      //print("exception $e");
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      //print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Payment Cancelled")),
      );
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((int.parse(amount)) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
        // 'automatic_payment_methods[enabled]': 'true',
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
      //print('Error: ${err.toString()}');
    }
  }
}

// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Stripe Payment',
//       home: StripeCardInputScreen(),
//     );
//   }
// }
//
// class StripeCardInputScreen extends StatefulWidget {
//   const StripeCardInputScreen({Key? key}) : super(key: key);
//
//   @override
//   State<StripeCardInputScreen> createState() => _StripeCardInputScreenState();
// }
//
// class _StripeCardInputScreenState extends State<StripeCardInputScreen> {
//   Map<String, dynamic>? paymentIntent;
//   CardDetails _cardDetails = CardDetails();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stripe Card Input'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Enter Card Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             CardField(
//               onCardChanged: (cardDetails) {
//                 setState(() {
//                   _cardDetails = cardDetails! as CardDetails;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//              onPressed: _cardDetails != null ? makePayment : null,
//               child: const Text('Pay Now'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> makePayment() async {
//     try {
//       // 1. Create Payment Intent
//       paymentIntent = await createPaymentIntent('100', 'GBP');
//
//       // 2. Confirm Payment
//       await Stripe.instance.confirmPayment(
//
//         data: const PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(
//             billingDetails: BillingDetails(
//               name: 'Test User',
//               email: 'testuser@example.com',
//               phone: '+441234567890',
//             ),
//           ),
//         ), paymentIntentClientSecret:  paymentIntent!['client_secret'],
//       );
//
//       // 3. Payment Successful
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment successful!")),
//       );
//
//       paymentIntent = null;
//     } on StripeException catch (e) {
//       //print('StripeException: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment failed or cancelled")),
//       );
//     } catch (e) {
//       //print('Error: $e');
//     }
//   }
//
//   Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': ((int.parse(amount)) * 100).toString(),
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };
//       var secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $secretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body,
//       );
//       return jsonDecode(response.body);
//       //print(response.body);
//     } catch (err) {
//       //print('Error creating Payment Intent: ${err.toString()}');
//       rethrow;
//     }
//   }
// }


// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Stripe Payment',
//       home: StripeCardInputScreen(),
//     );
//   }
// }
//
// class StripeCardInputScreen extends StatefulWidget {
//   const StripeCardInputScreen({Key? key}) : super(key: key);
//
//   @override
//   State<StripeCardInputScreen> createState() => _StripeCardInputScreenState();
// }
//
// class _StripeCardInputScreenState extends State<StripeCardInputScreen> {
//   Map<String, dynamic>? paymentIntent;
//   CardDetails _cardDetails = CardDetails();
//   bool _isProcessing = false; // To track payment process state
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stripe Card Input'),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               // mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Enter Card Details',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Card Information",
//                       style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 12.0),  // Space between title and the input field
//                     CardField(
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black87,
//                       ),
//                       decoration: const InputDecoration(
//                         hintText: 'Enter your card details',
//                         hintStyle: TextStyle(color: Colors.grey),
//                         contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                         ),
//                       ),
//                       onCardChanged: (cardDetails) {
//                         setState(() {
//                           _cardDetails = cardDetails! as CardDetails;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//
//
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _isProcessing || _cardDetails == null
//                       ? null
//                       : makePayment,
//                   child: const Text('Pay Now'),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> makePayment() async {
//     setState(() {
//       _isProcessing = true; // Show loader
//     });
//
//     try {
//       // 1. Create Payment Intent
//       paymentIntent = await createPaymentIntent('100', 'GBP');
//
//       // 2. Confirm Payment
//       await Stripe.instance.confirmPayment(
//         data: const PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(
//             billingDetails: BillingDetails(
//               name: 'Test User',
//               email: 'testuser@example.com',
//               phone: '+441234567890',
//             ),
//           ),
//         ),
//         paymentIntentClientSecret: paymentIntent!['client_secret'],
//       );
//
//       // 3. Payment Successful
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment successful!")),
//       );
//
//       paymentIntent = null;
//     } on StripeException catch (e) {
//       //print('StripeException: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment failed or cancelled")),
//       );
//     } catch (e) {
//       //print('Error: $e');
//     } finally {
//       setState(() {
//         _isProcessing = false; // Hide loader
//       });
//     }
//   }
//
//   Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': ((int.parse(amount)) * 100).toString(),
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };
//       var secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $secretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body,
//       );
//       return jsonDecode(response.body);
//     } catch (err) {
//       //print('Error creating Payment Intent: ${err.toString()}');
//       rethrow;
//     }
//   }
// }

// import 'dart:convert';
// import 'package:credit_card_validator/credit_card_validator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
//
//
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Stripe.publishableKey = 'pk_test_51OvKOKIpEtljCntg7LBirQmwmjL3Dh2nY4RzepYbuHrzpxLYpGZxYEKZAtfnJv3vMwzKjIMaAQhuajNzHTVl0CU900xp4xNCGq';
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Stripe Payment',
//       home: StripeCardInputScreen(),
//     );
//   }
// }
//
// class StripeCardInputScreen extends StatefulWidget {
//   const StripeCardInputScreen({Key? key}) : super(key: key);
//
//   @override
//   State<StripeCardInputScreen> createState() => _StripeCardInputScreenState();
// }
//
// class _StripeCardInputScreenState extends State<StripeCardInputScreen> {
//   Map<String, dynamic>? paymentIntent;
//   bool _isProcessing = false;
//
//   final TextEditingController _cardNumberController = TextEditingController();
//   final TextEditingController _expirationController = TextEditingController();
//   final TextEditingController _cvvController = TextEditingController();
//
//   final CreditCardValidator _cardValidator = CreditCardValidator();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stripe Card Input'),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const Text(
//                   'Enter Card Details',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Card Information",
//                       style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12.0),
//                     TextField(
//                       controller: _cardNumberController,
//                       decoration: const InputDecoration(
//                         hintText: 'Enter card number',
//                         contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       maxLength: 16,
//                     ),
//                     const SizedBox(height: 12.0),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _expirationController,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
//                               LengthLimitingTextInputFormatter(5),
//                             ],
//                             decoration: const InputDecoration(
//                               hintText: 'MM/YY',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextField(
//                             controller: _cvvController,
//                             decoration: const InputDecoration(
//                               hintText: 'CVV',
//                               contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                               ),
//                             ),
//                             keyboardType: TextInputType.number,
//                             maxLength: 3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _isProcessing ? null : makePayment,
//                   child: const Text('Pay Now'),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> makePayment() async {
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       // 1. Validate Card Number
//       final cardNumberValidation = _cardValidator.validateCCNum(_cardNumberController.text);
//       if (!cardNumberValidation.isValid) {
//         throw Exception('Invalid card number');
//       }
//
//       // 2. Validate Expiration Date
//       if (_expirationController.text.isEmpty || !_isValidExpirationDate(_expirationController.text)) {
//         throw Exception('Invalid expiration date');
//       }
//
//       // 3. Validate CVV
//       if (_cvvController.text.length != 3) {
//         throw Exception('Invalid CVV');
//       }
//
//       // 4. Create Payment Intent
//       paymentIntent = await createPaymentIntent('100', 'USD');
//
//       // Proceed with the payment process
//       final card = CardDetails(
//         number: _cardNumberController.text,
//         expirationMonth: int.parse(_expirationController.text.substring(0, 2)),
//         expirationYear: int.parse('20${_expirationController.text.substring(3, 5)}'),
//         cvc: _cvvController.text,
//       );
//
//       final paymentMethod = const PaymentMethodParams.card(
//         paymentMethodData: PaymentMethodData(
//           billingDetails: BillingDetails(
//             name: 'Test User',
//             email: 'testuser@example.com',
//             phone: '+441234567890',
//           ),
//         ),
//       );
//
//       // Make the payment
//       await Stripe.instance.confirmPayment(
//         data: paymentMethod,
//         paymentIntentClientSecret: paymentIntent!['client_secret'],
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment successful!")),
//       );
//
//     } on StripeException catch (e) {
//       //print('StripeException: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment failed or cancelled")),
//       );
//     } catch (e) {
//       //print('Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }
//
//   bool _isValidExpirationDate(String expiration) {
//     final parts = expiration.split('/');
//     if (parts.length != 2) return false;
//     final month = int.tryParse(parts[0]);
//     final year = int.tryParse('20${parts[1]}');
//     if (month == null || year == null || month < 1 || month > 12 || year < DateTime.now().year) {
//       return false;
//     }
//     return true;
//   }
//
//   Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': ((int.parse(amount)) * 100).toString(),
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };
//       var secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $secretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body,
//       );
//       return jsonDecode(response.body);
//     } catch (err) {
//       //print('Error creating Payment Intent: ${err.toString()}');
//       rethrow;
//     }
//   }
// }
