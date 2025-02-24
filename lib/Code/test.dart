import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:http/http.dart' as http;

import '../services/dio.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: EnterAmountScreen(),
//     );
//   }
// }
//
// class EnterAmountScreen extends StatefulWidget {
//   @override
//   _EnterAmountScreenState createState() => _EnterAmountScreenState();
// }
//
// class _EnterAmountScreenState extends State<EnterAmountScreen> {
//   ValueNotifier<double> amountNotifier = ValueNotifier<double>(0.0);
//   final TextEditingController _amountController = TextEditingController();
//
//   void _showKeypad(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return EnterAmountBottomSheet(amountNotifier: amountNotifier);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text("Enter Amount", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _showKeypad(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
//           ),
//           child: Text("Enter Amount", style: TextStyle(color: Colors.yellow, fontSize: 18)),
//         ),
//       ),
//     );
//   }
// }

class EnterAmountBottomSheet extends StatefulWidget {
  final ValueNotifier<double> amountNotifier;


  const EnterAmountBottomSheet({super.key, required this.amountNotifier});

  @override
  _EnterAmountBottomSheetState createState() => _EnterAmountBottomSheetState();
}

class _EnterAmountBottomSheetState extends State<EnterAmountBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  // List of preset amounts
  List<int> presetAmounts = [100, 200, 350, 50];

  // Function to handle key tap actions (numbers and backspace)
  void onKeyTap(String value) {
    setState(() {
      double currentAmount = widget.amountNotifier.value;

      if (value == "⌫") {
        // Handle backspace: Remove the last digit
        String currentText = _amountController.text;
        if (currentText.isNotEmpty) {
          currentText = currentText.substring(0, currentText.length - 1);
        }
        _amountController.text = currentText;

        if (currentText.isNotEmpty) {
          widget.amountNotifier.value = double.tryParse(currentText) ?? 0.0;
        } else {
          widget.amountNotifier.value = 0.0;
        }
      } else {
        // Add the pressed number to the amount
        String currentText = _amountController.text + value;
        _amountController.text = currentText;
        widget.amountNotifier.value = double.tryParse(currentText) ?? 0.0;
      }
    });
  }

  // Function to set preset amount directly
  void setPresetAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString(); // Update TextField with preset amount
      widget.amountNotifier.value = amount.toDouble(); // Update the ValueNotifier with the preset amount
    });
  }

  // Format the amount as currency
  String getFormattedAmount(double amount) {
    return NumberFormat("#,##0.00", "en_GB").format(amount); // Format as currency
  }
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add funds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
          ),
          const SizedBox(height: 10),
          // Display the formatted amount in a non-editable TextField
          ValueListenableBuilder<double>(
            valueListenable: widget.amountNotifier,
            builder: (context, amount, child) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  // color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Editable TextField
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.none,
                        decoration: InputDecoration(
                          hintText: "Amount",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none, // No border when focused
                          enabledBorder: InputBorder.none, // No border when enabled
                          contentPadding: EdgeInsets.zero, // Optional: removes extra padding
                        ),
                        onChanged: (text) {
                          widget.amountNotifier.value = double.tryParse(text) ?? 0.0;
                        },
                      ),
                    ),
                    Text("£", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),

          // Display preset amounts as chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presetAmounts.map((amount) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setPresetAmount(amount); // Set the selected preset amount in the TextField
                    },
                    child: Chip(
                      label: Text("£$amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.10),
                      labelStyle: TextStyle(color: AppTheme.primaryColor),
                      // deleteIcon: Icon(MingCute.check_circle_fill),
                      // onDeleted: () {
                      //   setPresetAmount(amount); // Set the selected preset amount in the TextField
                      // },
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: AppTheme.primaryColor, // Set the border color here
                          width: 1, // Adjust the width of the border if needed
                        ),
                        borderRadius: BorderRadius.circular(20), // Adjust the border radius if needed
                      ),
                      // deleteIconColor: AppTheme.primaryColor,  // Set the color of the delete icon (x)
                    ),
                  )



                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          // Numeric keypad
          NumericKeypad(onKeyTap: onKeyTap),
          SizedBox(height: 20),
          // Next button
          CustomButton(text: 'Next ${_amountController.text}', onPressed: () {
            Navigator.pop(context);
            saveCardAndMakePayment(context, _amountController.text.toString());
          }),
        ],
      ),
    );
  }

  Future<void> saveCardAndMakePayment(BuildContext context, String price) async {
    try {
      // Create payment intent
      var paymentIntent = await createPaymentIntent(price, 'GBP');
      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }

      String paymentIntentId = paymentIntent['id'];

      // Initialize the payment sheet
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

      // Show payment sheet and handle payment
      await displayPaymentSheet(context, price, paymentIntentId);

    } catch (e) {
      // Show error message if any error occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId) async {
    try {
      // Show loading dialog before presenting payment sheet
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CupertinoActivityIndicator());
        },
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Call postBookingData after successful payment
      await sendPostRequest(paymentIntentId, price);

      // Hide the loading dialog after payment is successful
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );

      // Reset the payment intent
      paymentIntent = null;
    } on StripeException catch (e) {
      // Hide the loading dialog in case of error
      Navigator.pop(context);

      // Show cancellation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled")),
      );
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount) * 100).round().toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
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

  final DioService _apiService = DioService();

  // Example method to make a POST request
  Future<void> sendPostRequest(String trxID, String amount) async {
    // Example data you want to send in the POST request
    Map<String, dynamic> data = {
      'userId': '890',
      'amount': amount,
      'transaction_id': trxID,
      'signature': '40',
    };

    // Sending the POST request
    Response? response = await _apiService.postRequest('wallet/add-funds', data);
    // Handling the response
    if (response != null && response.statusCode == 200) {
      // Pop the context if needed
      Navigator.pop(context);
      print('Data posted successfully: ${response.data}');
    } else {
      print('Failed to post data: ${response?.statusCode}');
    }
  }
}

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyTap;
  NumericKeypad({required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    List<String> keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "⌫"];
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.5,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onKeyTap(keys[index]),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              keys[index],
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}


