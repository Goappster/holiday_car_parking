import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart'as Material;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http ;

import 'booking_confirmation.dart';
import '../widgets/company_logo_widget.dart';
import '../widgets/company_details_widget.dart';
import '../widgets/info_column_widget.dart';
import '../services/payment_service.dart';

class BookingDetailsScreen extends StatefulWidget {
  // final Map<String, dynamic> company;
  const BookingDetailsScreen({super.key, });
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  String? token;
  Map<String, dynamic>? user;
  Map<String, dynamic>? paymentIntent;

  String? savedReferenceNo;
  late PaymentService paymentService;
  // @override
  // void initState() {
  //   super.initState();
  //
  // }

  late var confirmationSelected;
  late var cancellationCover;
  late var company;
  late var airportId;
  late var airportName;
  late var startDate;
  late var endDate;
  late var startTime;
  late var endTime;
  late var  totalDays;
  late double bookingPrice;
  late double totalPrice;
  late String registration; late String make; late String color; late String model;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    paymentService = PaymentService('sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    confirmationSelected = args['ConfirmationSelected'];
    cancellationCover = args['cancellationCover'];
    company = args['company'];
    airportId = args['AirportId'];
    airportName = args['AirportName'];
    startDate = args['startDate'];
    endDate = args['endDate'];
    startTime = args['startTime'];
    endTime = args['endTime'];
    totalDays = args['totalDays'];
    bookingPrice = (args['totalPrice'] as num).toDouble();
    totalPrice = bookingPrice + 1.99;
    registration = args['registration']; make = args['make']; color = args['color']; model = args['model'];

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:   Text('Booking Details $registration $make $model $color'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CompanyLogoWidget(company: company),
                  const SizedBox(width: 10),
                  CompanyDetailsWidget(company: company),
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
              buildDetailRow('Booking Price', '£${bookingPrice.toStringAsFixed(2)}'),
              buildDetailRow('Booking Fee', '£1.99'),
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
                    '£${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 22,),
              Material.Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CompanyLogoWidget(company: company),
                          const SizedBox(width: 10),
                          CompanyDetailsWidget(company: company),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InfoColumnWidget(icon: Icons.local_shipping, title: 'Drop-Off',
                              value: '$startDate at $startTime'),
                          InfoColumnWidget(icon: Icons.calendar_today, title: 'Return',
                              value: '$endDate at $endTime'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InfoColumnWidget(icon: Icons.attach_money, title: 'Booking Price',
                              value: '£${bookingPrice.toStringAsFixed(2)}'),
                          InfoColumnWidget(icon: Icons.percent, title: 'Booking Fee', value: '1.99'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showBottomSheet(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingConfirmation()));
                 // saveIncompleteBooking();
                },
                style: ElevatedButton.styleFrom(
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

  Future<void> saveCardAndMakePayment(BuildContext context, String price) async {
    try {
      var paymentIntent = await paymentService.createPaymentIntent(price, 'GBP');
      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }
      await paymentService.displayPaymentSheet(context, paymentIntent);
    } catch (e) {
      // Handle payment exception
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    return paymentService.createPaymentIntent(amount, currency);
  }

  Future<void> postBookingData(String price, String _paymentIntentId) async {
    final url = Uri.parse('https://holidayscarparking.uk/api/booking');

    try {
      final response = await http.post(
        url,
        body: {
          'referenceNo': '$savedReferenceNo',
          'title': '${user?['title']}',
          'first_name': '${user?['first_name']}',
          'last_name': '${user?['last_name']}',
          'email': '${user?['email']}',
          'contactno': '${user?['phone_number']}',
          'deprTerminal': '509',
          'deptFlight': 'ASD124',
          'returnTerminal': '510',
          'returnFlight': 'ASD125',
          'model': model,
          'color': color,
          'make': make,
          'registration': registration,
          'payment_status': 'success',
          'booking_amount': '$bookingPrice',
          'cancelfee': '4.99',
          'smsfee': '1.99',
          'booking_fee': '1.99',
          'discount_amount': '6.52',
          'total_amount': price,
          'intent_id': _paymentIntentId,
        },
      );

      if (response.statusCode == 200) {
        // //print('Booking successful: ${response.body}');
        Navigator.pushNamed(context, '/PaymentConfirm',
          arguments: {
            'company': company,
            'startDate': startDate,
            'endDate': endDate,
            'startTime': startTime,
            'endTime': endTime,
            'totalPrice': totalPrice,
          },
        );
      } else {
        // //print('Failed to book: ${response.reasonPhrase}');
      }
    } catch (e) {
      // //print('Error occurred while posting booking data: $e');
    }
  }


  Future<void> saveIncompleteBooking( ) async {
    final url = Uri.parse('https://holidayscarparking.uk/api/saveIncompleteBooking');
    final response = await http.post(
      url,
      body: {
        'title': '${user?['title']}',
        'first_name': '${user?['first_name']}',
        'last_name': '${user?['last_name']}',
        'email': '${user?['email']}',
        'contactno': '${user?['phone_number']}',
        'parking_type': '${company['parking_type']}',
        'drop_date': '$startDate',
        'drop_time': '$startTime',
        'pick_date':' $endDate',
        'pick_time': '$endTime',
        'total_days': '$totalDays',
        'airport_id': '$airportId',
        'product_id': '${company['companyID']}',
        'product_code': '${company['product_code']}',
        'park_api': '${company['park_api']}',
        'booking_amount': '$bookingPrice',
        'booking_fee': '1.99',
        'discount_amount': '4.29',
        'total_amount': '${bookingPrice + 1.99}',
        'promo': 'HCP-APP-OXT78U',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        savedReferenceNo = responseData['booking']['referenceNo']; // Store reference number
        //print('Reference No: $responseData');
      }
      // ('Booking successful: ${response.body}');


    } else {
      //print('Failed to book: ${response.reasonPhrase}');
    }
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

  final TextEditingController _promoController = TextEditingController(text: "POPFLUX44");
  String _promoState = "none";
  String _errorText = '';

  void applyPromoCode() {
    setState(() {
      if (_promoController.text == "POPFLUX44") {
        _promoState = "applied";
        _errorText = '';
      } else {
        _promoState = "expired";
        _errorText = 'Invalid Promo Code';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_promoState == "applied"
            ? "Promo Code Applied Successfully!"
            : "Promo Code Expired!"),
        backgroundColor: _promoState == "applied" ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void removePromoCode() {
    setState(() {
      _promoState = "removed";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Promo Code Removed"),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void togglePromoCode() {
    setState(() {
      if (_promoState == "applied") {
        _promoState = "removed";
        _promoController.clear();
        _errorText = '';
      } else {
        applyPromoCode();
      }
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          // color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Enter Promo Code',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _promoController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Promo code",
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.local_offer, color: Theme.of(context).primaryColor),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.paste, color: Colors.blueAccent),
                            //   onPressed: () async {
                            //     ClipboardData? data = await Clipboard.getData('text/plain');
                            //     if (data != null) {
                            //       setState(() {
                            //         _promoController.text = data.text ?? '';
                            //       });
                            //     }
                            //   },
                            // ),
                            TextButton(
                              onPressed: () {
                                togglePromoCode();
                                setModalState(() {});
                              },
                              child: Row(
                                children: [
                                  Text(_promoState == "applied" ? "Remove" : "Apply Promo", style: TextStyle(color: Theme.of(context).primaryColor)),
                                  // Icon(_promoState == "applied" ? Icons.close : Icons.check, color: Colors.blueAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                        errorText: _errorText.isEmpty ? null : _errorText,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_promoState == "applied") promoCodeApplied(),
                    // if (_promoState == "expired") promoCodeExpired(),
                    // if (_promoState == "removed") promoCodeRemoved(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.maybePop(context);
                          saveCardAndMakePayment(context, totalPrice.toString());
                        },
                        child: const Text("Proceed to Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget promoCodeApplied() {
    return promoCodeContainer(
      icon: Icons.check_circle,
      iconColor: Colors.green,
      text: "POPFLUX44 -\$20.00 (10% off)",
      message: "Promo Code Applied",
      messageColor: Colors.green,
      onRemove: removePromoCode,
    );
  }

  // Expired Promo Code UI
  Widget promoCodeExpired() {
    return promoCodeContainer(
      icon: Icons.error,
      iconColor: Colors.red,
      text: "POPFLUX44",
      message: "Promo Code Expired",
      messageColor: Colors.red,
      isError: true,
    );
  }

  // Removed Promo Code UI
  Widget promoCodeRemoved() {
    return promoCodeContainer(
      icon: Icons.info,
      iconColor: Colors.blue,
      text: "POPFLUX44",
      message: "Promo Code Removed",
      messageColor: Colors.blue,
    );
  }

  // Generic Promo Code UI Container
  Widget promoCodeContainer({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String message,
    required Color messageColor,
    bool isError = false,
    VoidCallback? onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    message,
                    style: TextStyle(color: messageColor),
                  ),
                ],
              ),
            ],
          ),
          // if (onRemove != null)
          //   TextButton(
          //     onPressed: onRemove,
          //     child: const Text("Remove", style: TextStyle(color: Colors.blue)),
          //   ),
        ],
      ),
    );
  }
}
