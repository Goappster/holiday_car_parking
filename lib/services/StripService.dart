import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/services/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

import 'Notifactions.dart';

class PaymentService {
  static const String _secretKey = "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";
  // static const String _secretKey = "sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc";
  final NotificationService _notificationService = NotificationService();
  final DioService _apiService = DioService();

  // Future<String?> createOrGetCustomer(String email, String name) async {
  //   try {
  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/customers'),
  //       headers: {
  //         'Authorization': 'Bearer $_secretKey',
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: {
  //         'email': email,
  //         'name': name,
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body); // Decode JSON
  //       print("Customer ID: ${data['id']}"); // Print customer ID
  //       return data['id'];
  //     } else {
  //       print("Failed to create/retrieve customer. Status code: ${response.statusCode}");
  //       print("Response: ${response.body}");
  //     }
  //   } catch (err) {
  //     print("Error creating/retrieving customer: $err");
  //   }
  //   return null;
  // }
  //
  // // Function to create payment intent with dynamic customer ID
  // Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency, String customerId) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': (double.parse(amount) * 100).round().toString(),
  //       'currency': currency,
  //       'customer': customerId, // Attach to customer
  //       'payment_method_types[]': 'card',
  //     };
  //
  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization': 'Bearer $_secretKey',
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     }
  //   } catch (err) {
  //     print("Error creating payment intent: $err");
  //   }
  //   return null;
  // }
  //
  // // Function to save card and make a payment
  // Future<void> saveCardAndMakePayment(BuildContext context, String price, String source, Map<String, dynamic> extraData) async {
  //   try {
  //     // Use actual user data instead of hardcoded values
  //     String email = extraData['email'] ?? "johndoe123@test.com";
  //     String name = extraData['name'] ?? "John Doe";
  //
  //     // Retrieve or create the customer ID
  //     String? customerId = await createOrGetCustomer(email, name);
  //     if (customerId == null) throw Exception("Failed to create/retrieve customer");
  //
  //     // Create payment intent for this customer
  //     var paymentIntent = await createPaymentIntent(price, 'GBP', 'cus_RssaM5k4r2c2h8');
  //     if (paymentIntent == null) throw Exception("Failed to create payment intent");
  //
  //     // Billing details
  //     BillingDetails billingDetails = BillingDetails(
  //       name: name,
  //       email: email,
  //       phone: extraData['phone'] ?? "+44 1234 567890",
  //       address: Address(
  //         city: extraData['city'] ?? "London",
  //         country: extraData['country'] ?? "GB",
  //         line1: extraData['address1'] ?? "221B Baker Street",
  //         line2: extraData['address2'] ?? "",
  //         postalCode: extraData['postalCode'] ?? "NW16XE",
  //         state: extraData['state'] ?? "England",
  //       ),
  //     );
  //
  //     // Initialize Payment Sheet
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: paymentIntent['client_secret'],
  //         merchantDisplayName: 'Holiday Car Parking',
  //         billingDetails: billingDetails,
  //         allowsDelayedPaymentMethods: true, // Allows saving cards
  //       ),
  //     );
  //
  //     await displayPaymentSheet(context, price, paymentIntent['id'], source, extraData);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }
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
        var data = jsonDecode(response.body);
        return data['id'];
      }
    } catch (err) {
      print("Error creating/retrieving customer: $err");
    }
    return null;
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency, String customerId) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount) * 100).round().toString(),
        'currency': currency,
        'customer': customerId,
        'payment_method_types[]': 'card',
        'setup_future_usage': 'off_session', // Save card for future payments
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
      }
    } catch (err) {
      print("Error creating payment intent: $err");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSavedCards(String customerId) async {
    try {
      var response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_methods?customer=$customerId&type=card'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (err) {
      print("Error retrieving saved cards: $err");
    }
    return [];
  }

  Future<Map<String, dynamic>?> createPaymentIntentWithSavedCard(
      String amount, String currency, String customerId, String paymentMethodId) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount) * 100).round().toString(),
        'currency': currency,
        'customer': customerId,
        'payment_method': paymentMethodId,
        'off_session': 'true',
        'confirm': 'true',
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
      }
    } catch (err) {
      print("Error charging saved card: $err");
    }
    return null;
  }

  Future<String?> showCardSelectionDialog(BuildContext context, List<Map<String, dynamic>> cards) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: cards.map((card) {
              String cardBrand = card['card']['brand'];
              String last4 = card['card']['last4'];
              return ListTile(
                title: Text("$cardBrand **** $last4"),
                onTap: () => Navigator.pop(context, card['id']),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> saveCardAndMakePayment(BuildContext context, String price, String source, Map<String, dynamic> extraData) async {
    try {
      String email = extraData['email'] ?? "johndoe123@test.com";
      String name = extraData['name'] ?? "John Doe";

      String? customerId = await createOrGetCustomer(email, name);
      if (customerId == null) throw Exception("Failed to retrieve customer");

      BillingDetails billingDetails = BillingDetails(
        email: email,
        name: name,
        address: Address(
          line1: "123 Main St",
          line2: "",
          city: "London",
          state: "London",
          postalCode: "WC1A 1AA",
          country: "GB",
        ),
      );

      List<Map<String, dynamic>> savedCards = await getSavedCards(customerId);

      String? selectedPaymentMethod;
      if (savedCards.isNotEmpty) {
        selectedPaymentMethod = await showCardSelectionDialog(context, savedCards);
      }

      Map<String, dynamic>? paymentIntent;
      if (selectedPaymentMethod != null) {
        paymentIntent = await createPaymentIntentWithSavedCard(price, 'GBP', customerId, selectedPaymentMethod);
      } else {
        paymentIntent = await createPaymentIntent(price, 'GBP', customerId);
      }

      if (paymentIntent == null) throw Exception("Payment intent creation failed");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          billingDetails: billingDetails,
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          allowsDelayedPaymentMethods: true,
        ),
      );

      await displayPaymentSheet(context, price, paymentIntent['id'], source, extraData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId, String source, Map<String, dynamic> extraData) async {
  //   try {
  //     await Stripe.instance.presentPaymentSheet();
  //
  //     if (source == 'booking') {
  //       await sendBooking(context, price, extraData, paymentIntentId);
  //     } else if (source == 'add_funds') {
  //       await sendPostRequest(context, paymentIntentId, price, extraData);
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Paid successfully")),
  //     );
  //   } on StripeException {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Payment Cancelled")),
  //     );
  //   }
  // }
  // Function to display payment sheet
  Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId, String source, Map<String, dynamic> extraData) async {
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
        const SnackBar(content: Text("Payment Cancelled")),
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
      _notificationService.showNotification(
          '🅿️ Parking Reserved – Ready for You ',
          '🚗 Your airport parking is confirmed!\n'
              'ReferenceNo: #${bookingDetails['referenceNo']}\n'
              'Parking Spot: ${bookingDetails['company']['name']}\n'
              'Drop-Off: ${bookingDetails['drop_date']} ${bookingDetails['drop_time']}\n'
              'Pick-Up: ${bookingDetails['pick_date']} ${bookingDetails['pick_time']}\n'
              // '🚀 Enjoy a hassle-free parking experience. Safe travels! ✈️'
      );
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
      _notificationService.showNotification(
          '🎉 Payment Received!',
          'Your payment of £$amount has been added to your wallet.\n'
              'Transaction ID: #$trxID\n'
              'Date & Time: ${DateFormat('EEE, dd MMM yyyy • HH:mm').format(DateTime.now())}\n'
              'Thanks for choosing HCP Wallet! 🚀'
      );
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