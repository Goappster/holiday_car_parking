import 'package:flutter/material.dart';
import 'package:holidayscar/screens/Wallet%20System/wtihdrwa_funds.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';


class BankSelectionScreen extends StatefulWidget {

   final String amount;
   final String userId;
  const BankSelectionScreen({super.key, required this.amount, required this.userId});

  @override
  _BankSelectionScreenState createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  String? selectedBank;
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountTitleController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bank"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Select a Bank",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Dropdown to select bank with an icon
                DropdownButtonFormField<String>(
                  value: selectedBank,
                  items: [
                    "Barclays", "HSBC", "Lloyds Bank", "NatWest", "Santander", "RBS (Royal Bank of Scotland)", "Monzo", "Starling Bank", "Nationwide", "TSB Bank",].map((bank) => DropdownMenuItem(
                    value: bank,
                    child: Row(
                      children: [
                        Icon(Icons.account_balance, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(bank),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBank = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Choose a bank",
                    // labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    // fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a bank";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Title for entering bank details
                const Text(
                  "Or Enter Bank Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Bank Name input with icon
                TextFormField(
                  controller: _accountTitleController,
                  decoration: InputDecoration(
                    labelText: "Account Title",
                    // labelStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    // fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the Account Title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Account Number input with an icon
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Account Number",
                    // labelStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(Icons.credit_card, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    // fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your account number";
                    }
                    if (value.length < 8) {
                      return "Account number must be at least 8 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Save & Continue button with minimalistic style
                CustomButton(text: 'Save & Continue', onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> WithdrwaFunds(amount: widget.amount, accountTitle: _accountTitleController.text, accountNumber: _accountNumberController.text, bankName: selectedBank.toString(), userId: widget.userId,) ));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}