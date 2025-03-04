import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/connectivity_provider.dart';
import '../../routes.dart';
import '../../services/Notifactions.dart';
import '../../services/dio.dart';
class WithdrwaFunds extends StatefulWidget {

  final String amount; final String accountTitle; final String accountNumber; final String bankName; final String userId;
  WithdrwaFunds({super.key, required this.amount, required this.accountTitle, required this.accountNumber, required this.bankName, required this.userId});

  @override
  State<WithdrwaFunds> createState() => _WithdrwaFundsState();
}

class _WithdrwaFundsState extends State<WithdrwaFunds> {
  final DioService _apiService = DioService();
  final NotificationService _notificationService = NotificationService();

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
                sendPostRequest(
                    context, widget.userId, widget.amount, widget.accountNumber,
                    widget.accountTitle);
              }),
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> BankSelectionScreen() ));
                  // sendPostRequest(context, widget.)
                },
                child: Text("Cancel withdraw",
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
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> sendPostRequest(BuildContext context, String userId,
      String amount, String accountNumber, String accountTitle) async {
    // Show Progress Dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) =>
          AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Processing..."),
              ],
            ),
          ),
    );

    Map<String, dynamic> data = {
      'userId': userId,
      'amount': amount,
      'transaction_id': 'Withdraw Request',
      'signature': '65465446554',
      'account_title': accountTitle,
      'sort_code': '40',
      'account_number': accountNumber,
    };

    try {
      Response? response = await _apiService.postRequest(
          'wallet/withdrawRequest', data);

      Navigator.pop(context); // Close progress dialog

      if (response != null && response.statusCode == 200) {
        _notificationService.showNotification(
          '🏦 Withdrawal Successful!',
          'You have withdrawn £$amount to your bank account.\n'
              'Transaction ID: Withdraw Request\n'
              'Date & Time: ${DateFormat('EEE, dd MMM yyyy • HH:mm').format(
              DateTime.now())}\n'
              'The amount will reflect in your bank shortly.',
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text(
                  'Amount has been successfully withdrawn to your bank.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.home, (route) => false);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showErrorDialog(context, "Failed to withdraw funds.");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if an error occurs
      showErrorDialog(context, "An error occurred: $e");
    }
  }

// Show Error Dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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



