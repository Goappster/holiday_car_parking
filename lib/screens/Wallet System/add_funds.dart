import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/wallet_provider.dart';
import '../../services/dio.dart';
import 'bank_selection.dart';

class EnterAmountBottomSheet extends StatefulWidget {
  final ValueNotifier<double> amountNotifier;
final String source;

  const EnterAmountBottomSheet({super.key, required this.amountNotifier, required this.source});

  @override
  _EnterAmountBottomSheetState createState() => _EnterAmountBottomSheetState();
}

class _EnterAmountBottomSheetState extends State<EnterAmountBottomSheet> {


  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user');

    if (userData != null) {
      try {
        setState(() {
          user = json.decode(userData);
        });
      } catch (e) {
        user = null;
      }
    }
  }
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
            if (widget.source == 'withdraw'){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> BankSelectionScreen(amount: _amountController.text, userId: user!['id'].toString(),) ));
            } else{
              saveCardAndMakePayment(context, _amountController.text.toString());
            }


          }),
        ],
      ),
    );
  }

  Future<void> saveCardAndMakePayment(BuildContext context, String price) async {
    try {
      paymentIntent = await createPaymentIntent(price, 'GBP');

      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }

      String paymentIntentId = paymentIntent!['id'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          googlePay: const PaymentSheetGooglePay(
            testEnv: false,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
        ),
      );

      await displayPaymentSheet(context, price, paymentIntentId);

    } catch (e) {
      //print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // Call postBookingData after successful payment
      await sendPostRequest(context, paymentIntentId, price);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );


      paymentIntent = null;
    } on StripeException catch (e) {
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
        //print("Stripe API Error: ${response.body}");
        return null;
      }
    } catch (err) {
      //print('Error: ${err.toString()}');
      return null;
    }
  }


  final DioService _apiService = DioService();
  Future<void> sendPostRequest(BuildContext context, String trxID, String amount) async {
    Map<String, dynamic> data = {
      'userId': user!['id'].toString(),
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


