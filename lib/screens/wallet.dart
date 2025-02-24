import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Code/test.dart';
import '../services/dio.dart';
import '../widgets/ImageSlider.dart';
import 'PaymentReceiptScreen.dart';

class WalletDashboard extends StatefulWidget {
  const WalletDashboard({super.key});

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  final List<String> images = [
    'https://i.pinimg.com/474x/c2/b0/1a/c2b01ac41b052535bc3871e85f86753c.jpg',
    'https://i.pinimg.com/736x/de/26/05/de26051a2c73292f11cd91b8ede87a66.jpg',
    'https://i.pinimg.com/736x/1a/26/fd/1a26fdceeec831daae488589936e2116.jpg',
  ];

  Map<String, dynamic>? user;
  Map<String, dynamic>? walletData;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  final DioService _apiService = DioService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    if (user != null) {
      await loadWalletBalance();
      await loadTransactions();
    }
    setState(() => isLoading = false);
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

  /// Helper method to safely parse wallet data.
  Map<String, dynamic> _parseWalletData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else {
      return {};
    }
  }

  Future<void> loadWalletBalance() async {
    if (user == null || user?['id'] == null) return;

    setState(() => isLoading = true);

    try {
      final response = await _apiService.postRequest('wallet/balance', {
        "userId": user!['id'].toString(),
      });

      setState(() {
        if (response != null && response.data['success'] == true) {
          walletData = _parseWalletData(response.data['wallet']);
        } else {
          walletData = {};
        }
      });
    } catch (e) {
      setState(() => walletData = {});
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadTransactions() async {
    if (user == null || user?['id'] == null) return;

    try {
      final response = await _apiService.postRequest('wallet/getTransactions', {
        "userId": user!['id'].toString(),
      });

      setState(() {
        if (response != null && response.data['success'] == true) {
          transactions = List<Map<String, dynamic>>.from(response.data['transactions']);
        } else {
          transactions = [];
        }
      });
    } catch (e) {
      setState(() => transactions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'HCP Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Updated Balance', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₤${walletData?['balance']?.toString() ?? "0"}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                  onPressed: () async {
                    await loadWalletBalance();
                    await loadTransactions();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildQuickAction(context, LucideIcons.circle, 'Add funds', (){showPaymentBottomSheet(context);}),
                _buildQuickAction(context, Icons.account_balance, 'Bank Transfer', (){}),
                _buildQuickAction(context, Icons.swap_horiz, 'Transfer', (){}),
                _buildQuickAction(context, LucideIcons.ticket, 'Voucher Code', (){}),
              ],
            ),
            SizedBox(height: 20),
            Text('Promo & Offers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ImageSlider(imageUrls: images),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECENT TRANSACTIONS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('View All',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor)),
              ],
            ),
            // Build list of transactions
            Column(
              children: transactions.map((tx) {
                bool isCredit = tx['type'] == 'credit';
                return ListTile(
                  leading: Icon(
                    isCredit ? LucideIcons.creditCard : LucideIcons.ticket,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                  title: Text(tx['description'] ?? ''),
                  subtitle: Text(DateFormat('EEEE, MMMM yyyy').format(DateTime.parse(tx['created_at']))),
                  trailing: Text(
                    '${isCredit ? "+" : "-"}${tx['amount'] ?? "0"}',
                    style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentReceiptScreen(),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.10),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  ValueNotifier<double> amountNotifier = ValueNotifier<double>(0.0);
  // final TextEditingController _amountController = TextEditingController();

  void _showKeypad(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EnterAmountBottomSheet(amountNotifier: amountNotifier);
      },
    );
  }

  void showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
              SizedBox(height: 16),
              Text(
                "How would you like to deposit in HCP Wallet?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
              ),
              SizedBox(height: 16),
              _buildPaymentOption(
                title: "Credit/Debit Cards",
                subtitle: "1 - 2 minutes\nMin £50 deposit\nRequires Credit/Debit Cards",
                image: "assets/images/Stripe_Logo.png", // Use image instead of icon
                additionalText: "Stripe is available in 195+ countries",
                  onTap: () {
                    Navigator.pop(context);
                    _showKeypad(context);
                  },
              ),
              SizedBox(height: 10),
              _buildPaymentOption(
                title: "Bank transfer or debit card",
                subtitle: "Requires registration\nOptions and fees vary based on location",
                image: "assets/images/visa_logo.png",
                additionalText: "Available in 59 countries",
                onTap: () {  },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  Widget _buildPaymentOption({
    required String title, required String subtitle, required String image, required String additionalText, required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          // color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey, // Change to your desired color
            width: 1, // Change to your desired border width
          ),
        ),
        child: Row(
          children: [
            Image.asset(image, width: 40, height: 40), // Display Image
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(additionalText, style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
