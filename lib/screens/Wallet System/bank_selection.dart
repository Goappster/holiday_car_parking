import 'package:flutter/material.dart';
import 'package:holidayscar/screens/Wallet%20System/wtihdrwa_funds.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:provider/provider.dart';

import '../../providers/connectivity_provider.dart';

class BankSelectionScreen extends StatefulWidget {
  final String amount, userId;
  const BankSelectionScreen({super.key, required this.amount, required this.userId});

  @override
  _BankSelectionScreenState createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountTitleController = TextEditingController();
  String? selectedBank;

  final List<String> banks = [
    "Barclays", "HSBC", "Lloyds Bank", "NatWest", "Santander",
    "RBS (Royal Bank of Scotland)", "Monzo", "Starling Bank", "Nationwide", "TSB Bank"
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          _showNoInternetDialog(context);
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Select Bank"), elevation: 0),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const TitleText("Select a Bank"),
                  _buildDropdown(),
                  const TitleText("Or Enter Bank Details"),
                  _buildTextField(_accountTitleController, "Account Title", Icons.person),
                  _buildTextField(_accountNumberController, "Account Number", Icons.credit_card, isNumber: true),
                  const SizedBox(height: 20),
                  CustomButton(
                      text: 'Save & Continue',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => WithdrwaFunds(
                              amount: widget.amount,
                              accountTitle: _accountTitleController.text,
                              accountNumber: _accountNumberController.text,
                              bankName: selectedBank ?? '',
                              userId: widget.userId,
                            ),
                          ));
                        }
                      }
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
  void _showNoInternetDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoInternetDialog(
          checkConnectivity: () {
            Provider.of<ConnectivityProvider>(context, listen: false).checkConnectivity();
          },
        ),
      );
    });
  }
  Widget _buildDropdown() => DropdownButtonFormField<String>(
    value: selectedBank,
    items: banks.map((bank) => DropdownMenuItem(
      value: bank,
      child: Row(children: [Icon(Icons.account_balance, color: AppTheme.primaryColor), const SizedBox(width: 8), Text(bank)]),
    )).toList(),
    onChanged: (value) => setState(() => selectedBank = value),
    decoration: _inputDecoration("Choose a bank"),
    validator: (value) => value == null ? "Please select a bank" : null,
  );

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter $label";
          if (isNumber && value.length < 8) return "$label must be at least 8 digits";
          return null;
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, [IconData? icon]) => InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
  );
}

class TitleText extends StatelessWidget {
  final String text;
  const TitleText(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  );
}
