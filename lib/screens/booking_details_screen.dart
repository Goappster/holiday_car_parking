import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'booking_confirmation.dart';

class BookingDetailsScreen extends StatefulWidget {
  // final Map<String, dynamic> company;
  const BookingDetailsScreen({super.key, });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  String? token;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      String? userData = prefs.getString('user');
      if (userData != null) {
        user = json.decode(userData);
      }
    });
  }


  ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(-1);

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final company = args['company'];
    final airportId = args['AirportId'];
    final airportName = args['AirportName'];
    final startDate = args['startDate'];
    final endDate = args['endDate'];
    final startTime = args['startTime'];
    final endTime = args['endTime'];
    final totalDays = args['totalDays'];
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    child: company['park_api'] == 'DB'
                        ? CachedNetworkImage(
                      imageUrl:
                      'https://airportparkbooking.uk/storage/${company['logo']}',
                      height: 40,
                      width: 60,
                       fit: BoxFit.cover,
                      // placeholder: (context, url) =>
                      //     const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    )
                        : company['park_api'] == 'holiday'
                        ? CachedNetworkImage(
                      imageUrl:
                      company['logo'],
                      height: 40,
                      width: 60,
                       fit: BoxFit.cover,
                      // placeholder: (context, url) =>
                      // const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    )
                        : null, // Optional: you can return an error widget if the condition doesn't match
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${company['name']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis, // Ensures the text truncates instead of overflowing
                        ),
                        Text('${company['parking_type']}'),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 26,),
               DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Theme.of(context).dividerColor, ),
              const SizedBox(height: 10,),
              buildDetailRow('Drop-Off', '$startDate at $startTime'),
              buildDetailRow('Return', '$endDate at $endTime'),
              buildDetailRow('No of Days', '$totalDays'),
              const SizedBox(height: 10,),
              DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Theme.of(context).dividerColor, ),
              const SizedBox(height: 10,),
              buildDetailRow('Booking Price', '£${company['price']}'),
              buildDetailRow('Booking Fee', '1.99'),
              const SizedBox(height: 10,),
               DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Theme.of(context).dividerColor, ),
              const SizedBox(height: 20,),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '£${company['price']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 22,),
              Card(

                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                            child: company['park_api'] == 'DB'
                                ? CachedNetworkImage(
                              imageUrl:
                              'https://airportparkbooking.uk/storage/${company['logo']}',
                              height: 40,
                              width: 60,
                              fit: BoxFit.cover,
                              // placeholder: (context, url) =>
                              //     const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            )
                                : company['park_api'] == 'holiday'
                                ? CachedNetworkImage(
                              imageUrl:
                              company['logo'],
                              height: 40,
                              width: 60,
                              fit: BoxFit.cover,
                              // placeholder: (context, url) =>
                              // const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            )
                                : null, // Optional: you can return an error widget if the condition doesn't match
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${company['name']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis, // Ensures the text truncates instead of overflowing
                                ),
                                Text('${company['parking_type']}'),
                              ],
                            ),
                          ),

                          // const Icon(Icons.edit, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(Icons.local_shipping, 'Drop-Off',
                              '$startDate at $startTime'),
                          _buildInfoColumn(Icons.calendar_today, 'Return',
                              '$endDate at $endTime'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                              Icons.attach_money, 'Booking Price', '£${company['price']}'),
                          _buildInfoColumn(
                              Icons.percent, 'Booking Fee', '1.99'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showPaymentOptions(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingConfirmation()));
                },
                style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    final List<Map<String, dynamic>> chipData = [
      {"label": "Visa", "image": "assets/images/visa_logo.png"},
      {"label": "PayPal", "image": "assets/images/paypal_logo.png"},
      {"label": "Apple Pay", "image": "assets/images/applepay_logo.png"},
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(chipData.length, (index) {
                  final chip = chipData[index];
                  return ValueListenableBuilder<int>(
                    valueListenable: _selectedIndexNotifier,
                    builder: (context, selectedIndex, _) {
                      final bool isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          _selectedIndexNotifier.value = index;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                chip["image"],
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                chip["label"],
                                // style: TextStyle(
                                //   color: isSelected ? Colors.white : Colors.black,
                                // ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  if (selectedIndex != -1) {
                    if (chipData[selectedIndex]["label"] == "Apple Pay") {
                      return _applePayLayout();
                    } else if (chipData[selectedIndex]["label"] == "PayPal") {
                      return _paypalLayout();
                    } else if (chipData[selectedIndex]["label"] == "Visa") {
                      return _visaLayout();
                    }
                  }
                  return Container(); // Empty container until a selection is made
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(context, 'Cancel', Theme.of(context).colorScheme.surface, Colors.red),
                  _buildButton(context, 'Confirm', Colors.red, Colors.white),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {
        // saveBookingDetails();
       Navigator.maybePop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: const Size(150, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.red),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _applePayLayout() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Apple Pay Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Enter your Apple Pay details here."),
          // You can add Apple Pay-specific widgets here.
        ],
      ),
    );
  }

  Widget _paypalLayout() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PayPal Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Log in to your PayPal account."),
          // You can add PayPal-specific widgets here.
        ],
      ),
    );
  }

  Widget _visaLayout() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Visa Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Enter your Visa card details."),
          // You can add Visa-specific widgets here.
        ],
      ),
    );
  }


  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

