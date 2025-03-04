import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:holidayscar/screens/Wallet%20System/transaction_History.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/UiHelper.dart';
import '../Booking/PaymentReceiptScreen.dart';
import 'add_funds.dart';
import '../../widgets/ImageSlider.dart';

class WalletDashboard extends StatefulWidget {
  const WalletDashboard({super.key});

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    if (user != null) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.loadWalletBalance(user!['id'].toString());
      await walletProvider.loadTransactions(user!['id'].toString()); // Load only once
    }
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
  // void showSortModal(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return const SortModalContent();
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          _showNoInternetDialog(context);
        }

        return  Scaffold(
          appBar: AppBar(
            surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text('HCP Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
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
                      '₤${walletProvider.walletData?['balance']?.toString() ?? "0"}',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () async {
                        await walletProvider.loadWalletBalance(user!['id'].toString(),);
                        await walletProvider.loadTransactions(user!['id'].toString(), forceReload: true); // Only reload on click
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
                    _buildQuickAction(context, Icons.account_balance, 'Withdraw Funds', ()=>showShowWithdrwaScreen(context)),
                    _buildQuickAction(context, Icons.swap_horiz, 'Transfer', (){
                      // showSortModal(context);
                      _showMessage(context, 'Coming Soon!');
                    }),
                    _buildQuickAction(context, LucideIcons.ticket, 'Voucher Code', (){
                      _showMessage(context, 'Coming Soon!');
                    })
                  ],
                ),
                SizedBox(height: 20),
                Text('Promo & Offers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ImageSlider(imageUrls: [
                  'https://i.pinimg.com/474x/c2/b0/1a/c2b01ac41b052535bc3871e85f86753c.jpg',
                  'https://i.pinimg.com/736x/de/26/05/de26051a2c73292f11cd91b8ede87a66.jpg',
                  'https://i.pinimg.com/736x/1a/26/fd/1a26fdceeec831daae488589936e2116.jpg',
                ]),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RECENT TRANSACTIONS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
                        );
                      },
                      child: Text('View All',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                walletProvider.isLoadingTransactions
                    ? Center(child: Text("Loading transactions...", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)))
                    : walletProvider.transactions.isEmpty
                    ? Center(child: Text("No transactions available", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)))
                    : Column(
                  children: walletProvider.transactions.take(5).map((tx) {
                    bool isCredit = tx['type'] == 'credit';
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isCredit
                              ? Icons.credit_card
                              : Icons.remove_circle,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                        title: Text(tx['description'] ?? ''),
                        subtitle: Text(
                          DateFormat('EEEE MMMM yyyy hh:mm a')
                              .format(DateTime.parse(tx['created_at'])),
                        ),
                        trailing: Text(
                          '${isCredit ? "+" : "-"}${tx['amount'] ?? "0"}',
                          style: TextStyle(
                            color: isCredit ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentReceiptScreen(
                                data: tx,
                                source: 'transactions',
                              ),
                            ),
                          );
                        }, // No navigation on tap
                      ),
                    );
                  }).toList(),
                ),
              ],
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


  void _showMessage(BuildContext context, String source) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(source),
        duration: Duration(seconds: 2), // Duration for how long the Snackbar will be visible,
      ),
    );
  }

  ValueNotifier<double> amountNotifier = ValueNotifier<double>(0.0);
  // final TextEditingController _amountController = TextEditingController();

  void _showKeypad(BuildContext context, String source) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EnterAmountBottomSheet(amountNotifier: amountNotifier, source: source, );
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
                    _showKeypad(context, 'deposit');
                  },
              ),
              // SizedBox(height: 10),
              // _buildPaymentOption(
              //   title: "Bank transfer or debit card",
              //   subtitle: "Requires registration\nOptions and fees vary based on location",
              //   image: "assets/images/visa_logo.png",
              //   additionalText: "Available in 59 countries",
              //   onTap: () {  },
              // ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showShowWithdrwaScreen(BuildContext context) {
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
                "How would you like to Withdraw in Bank Account?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
              ),
              // SizedBox(height: 16),
              // _buildPaymentOption(
              //   title: "Credit/Debit Cards",
              //   subtitle: "1 - 2 minutes\nMin £50 deposit\nRequires Credit/Debit Cards",
              //   image: "assets/images/Stripe_Logo.png", // Use image instead of icon
              //   additionalText: "Stripe is available in 195+ countries",
              //   onTap: () {
              //
              //   },
              // ),
              SizedBox(height: 10),
              _buildPaymentOption(
                title: "Bank Transfer",
                subtitle: "Requires bank details\nOptions and fees vary based on Bank",
                image: "assets/images/visa_logo.png",
                additionalText: "Available Only in UK Any Bank",
                onTap: () {
                  Navigator.pop(context);
                  _showKeypad(context, 'withdraw');

                },
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
