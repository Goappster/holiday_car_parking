import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/wallet_provider.dart';
import '../services/Notifactions.dart';
import 'package:http/http.dart' as http;

import '../services/StripService.dart';

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
      await walletProvider.loadWalletBalance(user!['id'].toString());
      await walletProvider.loadTransactions(user!['id'].toString());
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




  final bool _smsConfirmationSelected = false;
  final bool _cancellationCoverSelected = false;

  final NotificationService _notificationService = NotificationService();
  bool isLoading = false;

  Future<void> _handlePayment(BuildContext context) async {
    // Show loading dialog if not already loading
    if (!isLoading) {
      isLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissal by tapping outside
        builder: (context) => const Center(child: CupertinoActivityIndicator()),
      );
    }

    try {
      await PaymentService().saveCardAndMakePayment(context, widget.totalPrice, 'booking', widget.bookingDetails);
      print("Payment process completed!");
    } catch (e) {
      print("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      if (context.mounted) {
        print("Dismissing loading dialog...");
        Navigator.pop(context); // Dismiss the loading dialog
      }
    }
  }
  // bool isLoading = false;
  // late BuildContext dialogContext;
  //
  // Future<void> _handlePayment(BuildContext context) async {
  //   // Show loading dialog if not already loading
  //   if (!isLoading) {
  //     isLoading = true;
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false, // Prevent dismissal by tapping outside
  //       builder: (context) => const Center(child: CupertinoActivityIndicator()),
  //     );
  //   }
  //
  //   try {
  //     // Perform payment process
  //     await PaymentService().saveCardAndMakePayment(context, '5', 'add_funds', flightDetails);
  //
  //     // Optionally handle success
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Payment Successful!")),
  //     );
  //   } catch (e) {
  //     // Handle errors during payment
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Payment failed: $e")),
  //     );
  //   } finally {
  //     // Safely dismiss loading dialog once the process is done
  //     if (dialogContext.mounted) {
  //       Navigator.of(dialogContext).pop(); // Dismiss the loading dialog using stored dialog context
  //     }
  //     isLoading = false;  // Reset loading state
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
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
                                Text(
                             'Available Balance: ₤${walletProvider.walletData?['balance']?.toString() ?? "0"}',
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
          CustomButton(text: 'Continue', onPressed: () async {
            if (selectedIndex == 0) {
              postBookingData(widget.totalPrice, 'Wallet');
              if (walletProvider.walletData?['balance']?.toString() != null) {
                postBookingData(widget.totalPrice, 'Wallet');
                // print(widget.bookingDetails['referenceNo']);
                // print(widget.bookingDetails['title']);
                // print(widget.bookingDetails['first_name']);
                // print(widget.bookingDetails['email']);
                // print(widget.bookingDetails['contactno']);
                // print(widget.bookingDetails['deprTerminal']);
                // print(widget.bookingDetails['returnTerminal']);
                // print(widget.bookingDetails['model']);
                // print(widget.bookingDetails['booking_amount']);

                // Parse the balance string to a double
                double balance = double.tryParse(walletProvider.walletData?['balance']?.toString() ?? '') ?? 0.0;
                double totalPrice = double.tryParse(widget.totalPrice.toString()) ?? 0.0;

                // Compare the totalPrice and balance
                // If totalPrice is greater than or equal to balance
                if (totalPrice >= balance) {
                  // Display a Scaffold SnackBar if the total price is greater than or equal to the balance
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Total price is greater than or equal to your balance."),
                      duration: Duration(seconds: 2), // Customize duration
                    ),
                  );
                  print(walletProvider.walletData?['balance']?.toString());
                }

                // If totalPrice is less than the balance
                if (totalPrice < balance) {
                  postBookingData(totalPrice.toString(), 'Wallet');
                  // Show Scaffold SnackBar message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Your balance is sufficient. You can proceed to booking."),
                      duration: Duration(seconds: 2), // Customize duration
                    ),
                  );
                  // Proceed to the booking process here
                  // For example: bookingFunction();
                }

                // If balance is greater than total price (this condition is redundant and unnecessary as part of the above conditions)
                // Since `totalPrice < balance` already covers this case, you don't need this separate check
              } else {
                // Show Scaffold SnackBar if balance is unavailable
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Balance is not available."),
                    duration: Duration(seconds: 2), // Customize duration
                  ),
                );
              }
            } else if (selectedIndex == 1) {
             Navigator.maybePop(context);
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
  Future<void> postBookingData(String price, String paymentIntentId) async {
    final url = Uri.parse('https://holidayscarparking.uk/api/booking');

    Map<String, String> bookingData = {
      'referenceNo':  '131313351',
      'title': widget.bookingDetails['title'],
      'first_name': widget.bookingDetails['first_name'],
      'last_name':  widget.bookingDetails['last_name'],
      'email':  widget.bookingDetails['email'],
      'contactno':  widget.bookingDetails['contactno'],
      'deprTerminal':  widget.bookingDetails['deprTerminal'],
      'deptFlight':  widget.bookingDetails['deptFlight'],
      'returnTerminal':  widget.bookingDetails['returnTerminal'],
      'returnFlight':  widget.bookingDetails['returnFlight'],
      'model':  widget.bookingDetails['model'],
      'color':  widget.bookingDetails['color'],
      'make': widget.bookingDetails['make'],
      'registration':  widget.bookingDetails['registration'],
      'payment_status': 'wallet',
      'booking_amount':  widget.bookingDetails['booking_amount'],
      'cancelfee': widget.bookingDetails['cancelfee'],
      'smsfee': widget.bookingDetails['smsfee'],
      'booking_fee': widget.bookingDetails['booking_fee'],
      'discount_amount': widget.bookingDetails['discount_amount'],
      'total_amount': price,
      'intent_id': 'booking via wallet', // Fixed intent ID issue
    };

    //print("Sending booking data: $bookingData");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bookingData,
      );

      if (response.statusCode == 200) {
        print(response.body);
        _notificationService.showNotification(widget.bookingDetails['referenceNo']);
        // Navigator.pushNamed(
        //   context,
        //   '/PaymentConfirm',
        //   arguments: {
        //     'company': widget.bookingDetails['company'],
        //     'startDate': startDate,
        //     'endDate': endDate,
        //     'startTime': startTime,
        //     'endTime': endTime,
        //     'totalPrice': totalPrice,
        //     'referenceNo': '$savedReferenceNo',
        //   },
        // );
      } else {
      }
    } catch (e) {
    }
  }
}

//






