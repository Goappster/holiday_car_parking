import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/wallet_provider.dart';
import '../screens/Wallet System/add_funds.dart';
import '../screens/Wallet System/wallet.dart';
import '../services/Notifactions.dart';
import 'package:http/http.dart' as http;

import '../services/StripService.dart';
import '../services/dio.dart';

class SortModalContent extends StatefulWidget {
   const SortModalContent({super.key, required this.bookingDetails, required this.totalPrice, });
  final Map<String, dynamic> bookingDetails;
  final String totalPrice;

  @override
  _SortModalContentState createState() => _SortModalContentState();
}

class _SortModalContentState extends State<SortModalContent> {
  int selectedIndex = 0;
  final List<String> options = ['HCP Wallet', 'Credit/Debit Card'];
  final List<String> details = ['Best Free ZERO fees', 'Fees: 2.5%'];
  final List<String> balances = ['Balance: \$999999.00', ''];
  final List<String> promotions = ['Promotions', ''];
  final List<String> logos = [
    'assets/images/Logo.png',
    'assets/images/Stripe_Logo.png',
  ];

  Map<String, dynamic>? user;
  Map<String, dynamic> flightDetails = {};
  final String Data = '100';
  @override
  void initState() {
    super.initState();
    _initialize();
    _loadUserData();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    if (user != null) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      walletProvider.loadWalletBalance(user!['id'].toString());
      flightDetails = {
        'user_id': user!['id'].toString(),
        'departure': Data,
        'arrival': '2025-03-12',
        'from': 'London',
        'to': 'Paris',
      };
    }
  }

  // Now initialize flightDetails after user is loaded




  // Map<String, dynamic> flightDetails = {
  //   'uerId': user!['id'].toString(),
  //   'departure': '2025-03-10',
  //   'arrival': '2025-03-12',
  //   'from': 'London',
  //   'to': 'Paris',
  // };
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

  final NotificationService _notificationService = NotificationService();
  bool isLoading = false;

  late ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }


  Future<void> _handlePayment(BuildContext context) async {

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
      await PaymentService().saveCardAndMakePayment(context, widget.totalPrice, 'booking', widget.bookingDetails);
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

  final DioService _apiService = DioService();
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final bookingDetails = widget.bookingDetails;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Payment Options List
          Column(
            children: List.generate(options.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedIndex == index
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(logos[index], width: 40, height: 40),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                options[index],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                details[index],
                                style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                              ),
                              if (balances[index].isNotEmpty)
                                Consumer<WalletProvider>(
                                  builder: (context, walletProvider, child) {
                                    return Text(
                                      'Available Balance: ₤${walletProvider.walletData?['balance']?.toString() ?? "0"}',
                                    );
                                  },
                                ),
                              if (promotions[index].isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Recommended',
                                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (selectedIndex == index)
                        const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          // Confirm Button
          CustomButton(
            text: 'Continue',
            onPressed: () async {
              if (selectedIndex == 0) {
                if (walletProvider.walletData?['balance']?.toString() != null) {
                  Navigator.maybePop(context);
                  double balance = double.tryParse(walletProvider.walletData?['balance']?.toString() ?? '') ?? 0.0;
                  double totalPrice = double.tryParse(widget.totalPrice.toString()) ?? 0.0;
                  if (totalPrice >= balance) {
                    showCupertinoDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: const Text('Low Balance'),
                          content: const Text('⚠️ Your balance is low! Please deposit funds into your HCP wallet 💰 to continue enjoying smooth parking bookings. 🚗'),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            CupertinoDialogAction(
                              onPressed: () =>  Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  WalletDashboard()),
                              ),
                              child: const Text(
                                'Add funds 💳',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Total price is greater than or equal to your balance."),
                        duration: Duration(seconds: 2), // Customize duration
                      ),
                    );

                  }
                  if (totalPrice < balance) {
                    Navigator.maybePop(context);
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
                      await debitFunds(context, totalPrice.toString(), bookingDetails);
                      // Close loading dialog before sending booking
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      // Call booking API
                     await sendBooking(context, totalPrice.toString(), bookingDetails);
                     //  Navigator.pushNamed(
                     //    context,
                     //    '/PaymentConfirm',
                     //    arguments: {
                     //      'company': bookingDetails['company'],
                     //      'startDate': bookingDetails['drop_date'].toString(),
                     //      'endDate': bookingDetails['endDate'].toString(),
                     //      'startTime': bookingDetails['drop_time'].toString(),
                     //      'endTime': bookingDetails['pick_time'].toString(),
                     //      'totalPrice': widget.totalPrice.toString(),
                     //      'referenceNo': bookingDetails['referenceNo'].toString(),
                     //    },
                     //  );
                      // Show success dialog
                      if (context.mounted) {
                        Navigator.pop(context);
                        setState(() {
                          walletProvider.loadWalletBalance(user!['id'].toString());
                        });
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => AlertDialog(
                        //     title: Text("Success"),
                        //     content: Text("Your booking has been completed successfully!"),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () {
                        //           setState(() {
                        //             walletProvider.loadWalletBalance(user!['id'].toString());
                        //           });
                        //           Navigator.pop(context);
                        //         },
                        //         child: Text("OK"),
                        //       ),
                        //     ],
                        //   ),
                        // );
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


                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Balance is not available."),
                      duration: Duration(seconds: 2), // Customize duration
                    ),
                  );
                }
              } else if (selectedIndex == 1) {
                Navigator.maybePop(context);
                await _handlePayment(context);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> sendBooking(BuildContext context, String price, Map<String, dynamic> bookingDetails) async {
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
      'intent_id': 'booking via wallet',
    };

    Response? response = await _apiService.postRequest('booking', bookingData);
    if (response?.statusCode == 200) {
      print("Booking failed: ${response}");
      _notificationService.showNotification(bookingDetails['referenceNo']);
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

  Future<void> debitFunds(BuildContext context, String price, Map<String, dynamic> bookingDetails) async {
    try {
      Map<String, String> data = {
        'userId': bookingDetails['user_id'],
        'amount': price,
        'transaction_id': bookingDetails['referenceNo'],
        'signature': 'gdfgdgdgdg',
      };

      Response? response = await _apiService.postRequest('wallet/debitfunds', data);
      if (response?.statusCode == 200) {
        print("Success: ${response?.data}");
        // _notificationService.showNotification(bookingDetails['referenceNo']);
      } else {
        print("Booking failed: ${response?.statusCode} - ${response?.data}");
        throw Exception("Failed to complete booking");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("An error occurred while processing the payment.");
    }
  }
}







