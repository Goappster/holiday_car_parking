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
import '../../services/StripService.dart';
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

  List<int> presetAmounts = [100, 200, 350, 50];

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




  Future<void> _handlePayment(BuildContext context) async {
    Map<String, dynamic> details  = {
      'user_id': '${user!['id']}',

    };
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Processing..."),
            ],
          ),
        ),
      );

      // Debit funds
      await PaymentService().saveCardAndMakePayment(context, _amountController.text, 'add_funds', details);
      // Close loading dialog before sending booking
      if (context.mounted) {
        Navigator.pop(context);
      }
      // Show success dialog
      if (context.mounted) {
        Navigator.pop(context);

      }
    } catch (e) {
      // Close loading dialog in case of error
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Booking Failed"),
            content: Text("Something went wrong. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }



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
          CustomButton(
            text: 'Next',
            onPressed: () async {
              double amount = double.tryParse(_amountController.text.toString()) ?? 0.0;

              if (widget.source == 'withdraw') {
                if (amount >= 100) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BankSelectionScreen(
                        amount: _amountController.text,
                        userId: user!['id'].toString(),
                      ),
                    ),
                  );
                } else {
                  _showAlertDialog(context, '⚠️',
                      'You must withdraw at least £100 from your HCP wallet.');
                }
              } else {
                if (amount >= 50) {
                  await _handlePayment(context);
                } else {
                  _showAlertDialog(context, 'Low Amount ⚠️',
                      'Your amount is too low! Please deposit a minimum of £50 into your HCP wallet.');
                }
              }
            },
          )
        ],
      ),
    );
  }
  void _showAlertDialog(BuildContext context, String title, String message) {
    showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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


