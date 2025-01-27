// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:holidayscar/services/StripService.dart';
//
// class PaymentForm extends StatefulWidget {
//   @override
//   _PaymentFormState createState() => _PaymentFormState();
// }
//
// class _PaymentFormState extends State<PaymentForm> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String cardNumber = '';
//   String expiryDate = '';
//   String cvc = '';
//
//   // Payment processing function
//   Future<void> _processPayment() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();
//
//       try {
//         // Initialize Stripe
//         StripeService.init();
//
//         // Create a payment method
//         final paymentMethod = await StripeService.createPaymentMethod(
//           cardNumber: cardNumber,
//           expiryDate: expiryDate,
//           cvc: cvc,
//         );
//
//         // Send payment method ID to the backend to save
//         final response = await http.post(
//           Uri.parse('https://your-backend.com/save-payment-method'),
//           body: {'paymentMethodId': paymentMethod.id},
//         );
//
//         if (response.statusCode == 200) {
//           // Successfully saved payment method
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Card saved successfully!')),
//           );
//         } else {
//           // Handle error
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to save card.')),
//           );
//         }
//       } catch (e) {
//         // Handle error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: <Widget>[
//           TextFormField(
//             decoration: InputDecoration(labelText: 'Card Number'),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter a card number';
//               }
//               return null;
//             },
//             onSaved: (value) {
//               cardNumber = value ?? '';
//             },
//           ),
//           TextFormField(
//             decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
//             keyboardType: TextInputType.datetime,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the expiry date';
//               }
//               return null;
//             },
//             onSaved: (value) {
//               expiryDate = value ?? '';
//             },
//           ),
//           TextFormField(
//             decoration: InputDecoration(labelText: 'CVC'),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter CVC';
//               }
//               return null;
//             },
//             onSaved: (value) {
//               cvc = value ?? '';
//             },
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _processPayment,
//             child: Text('Pay Now'),
//           ),
//         ],
//       ),
//     );
//   }
// }
