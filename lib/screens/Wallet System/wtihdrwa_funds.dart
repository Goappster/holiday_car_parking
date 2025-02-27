import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';

import '../../routes.dart';
import '../../services/dio.dart';
class WithdrwaFunds extends StatefulWidget {

  final String amount; final String accountTitle; final String accountNumber; final String bankName; final String userId;
  WithdrwaFunds({super.key, required this.amount, required this.accountTitle, required this.accountNumber, required this.bankName, required this.userId});

  @override
  State<WithdrwaFunds> createState() => _WithdrwaFundsState();
}

class _WithdrwaFundsState extends State<WithdrwaFunds> {
  final DioService _apiService = DioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Text(
                "Withdraw \£${widget.amount}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Transfer should arrive on March 02",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildDetailRow("From", "HCP Wallet"),
                    _buildDetailRow("To", "${widget.bankName} ••4458"),
                    _buildDetailRow("Payment Method", widget.bankName),
                    _buildDetailRow("Fee", "\£0.05"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You can cancel your withdrawal within the first few minutes after submitting.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              CustomButton(text: 'Confirm', onPressed: () {
                sendPostRequest(context, widget.userId, widget.amount, widget.accountNumber, widget.accountTitle);
              }),
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> BankSelectionScreen() ));
                  // sendPostRequest(context, widget.)
                },
                child:  Text("Cancel withdraw",
                    style: TextStyle(color: AppTheme.primaryColor)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> sendPostRequest(BuildContext context, String userId, String amount, String accountNumber , String accountTitle) async {
    Map<String, dynamic> data = {
      'userId': userId,
      'amount': amount,
      'transaction_id': 'Withdraw Request',
      'signature': '65465446554',
      'account_title': accountTitle,
      'sort_code': '40',
      'account_number': accountNumber,
    };
    Response? response = await _apiService.postRequest('wallet/withdrawRequest', data);
    if (response != null && response.statusCode == 200) {
      // Show Cupertino-style success dialog
      print(response.data);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Amount has been successfully Withdraw to your Bank.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false,);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print(response?.data);
      // Show Cupertino-style error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to withdraw funds: .statusCode}'),
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





