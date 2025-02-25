import 'dart:convert';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart'as Material;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http ;

import '../../services/Notifactions.dart';
import '../../widgets/company_logo_widget.dart';
import '../../widgets/company_details_widget.dart';
import 'package:intl/intl.dart';
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

  // @override
  // void initState() {
  //   super.initState();
  //
  // }

  late var ArrivalFlightNo;
  late var DepartureFlightNo;
  late var company;
  late var airportId;
  late var airportName;
  late var startDate;
  late var endDate;
  late var startTime;
  late var endTime;
  late var  totalDays;
  late var  returnTerminal;
  late var  deprTerminal;
  late double bookingPrice;
  late double totalPrice;
   // Add this variable
  late String registration; late String make; late String color; late String model;
  
  // user details
  
  late String firstName; late String lastName; late String phoneNumber; late String title;

  double smsFees = 1.99;
  double cancellationFees = 1.99;
  double bookingFees = 1.99;

  bool _smsConfirmationSelected = false;
  bool _cancellationCoverSelected = false;

  final NotificationService _notificationService = NotificationService();
  String _permissionStatus = "Unknown";


  void _updatePermissionStatus() async {
    String status = await _notificationService.checkPermissionStatus();
    setState(() {
      _permissionStatus = status;
    });

    if (status == "Permanently Denied") {
      _showSettingsDialog();
    }
    if (status == "Denied") {
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notification Permission Required"),
        content: Text(
          "Notifications are permanently denied. Please enable them from settings.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updatePermissionStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    ArrivalFlightNo = args['ArrivalFlightNo'];
    DepartureFlightNo = args['DepartureFlightNo'];
    company = args['company'];
    airportId = args['AirportId'];
    airportName = args['AirportName'];
    startDate = args['startDate'];
    endDate = args['endDate'];
    startTime = args['startTime'];
    endTime = args['endTime'];
    totalDays = args['totalDays'];
    bookingPrice = args['totalPrice'];
    totalPrice = bookingPrice + calculateTotalFees();
    // baseTotalPrice = bookingPrice; // Initialize baseTotalPrice here
    registration = args['registration']; make = args['make']; color = args['color']; model = args['model'];
    deprTerminal = args['deprTerminal'];
    returnTerminal = args['returnTerminal'];
    
    // user info
    firstName = args['firstName']; lastName = args['lastName']; phoneNumber = args['phoneNumber']; title = args['title'];
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
        title:   Text('Booking Details'),
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
              SizedBox(
                width: double.infinity,
                child: Material.Card(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Drop-Off Date', style: Theme.of(context).textTheme.titleSmall?.copyWith( fontWeight: FontWeight.bold),),
                                Row(
                                  children: [
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: const Color(0xFF1D9DD9)
                                              .withOpacity(0.20)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SvgPicture.asset(
                                          'assets/map_blue.svg',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                               /*     DateFormat('dd/MM/yyyy').format(startDateTime)*/
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$startDate'),
                                        Text(
                                          '$startTime',
                                          style: TextStyle(color: Colors.grey),  // Change the color here
                                        )
                                      ],
                                    ),

                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: 0),

                            Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Return Date', style: Theme.of(context).textTheme.titleSmall?.copyWith( fontWeight: FontWeight.bold),),
                                Row(
                                  children: [
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: const Color(0xFF33D91D)
                                              .withOpacity(0.20)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SvgPicture.asset(
                                          'assets/map.svg',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$endDate'),
                                        Text(
                                          "at $endTime",
                                          style: TextStyle(color: Colors.grey, ),  // Change the color here
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color(0xFFB11DB4)
                                          .withOpacity(0.20)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset(
                                      'assets/booking_price.svg',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Booking Price'),
                                    Text(
                                      '£$bookingPrice',
                                      style: TextStyle(color: Colors.grey),  // Change the color here
                                    )
                                  ],
                                ),

                              ],
                            ),
                            SizedBox(width: 0),

                            Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color(0xFFED1C24)
                                          .withOpacity(0.20)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset(
                                      'assets/booking_fee.svg',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Booking Fee'),
                                    Text(
                                      '£1.99',
                                      style: TextStyle(color: Colors.grey),  // Change the color here
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 12),
               _buildSectionTitle('Explore Additional Services'),
              _buildAdditionalServices(context, totalPrice),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _showBottomSheet(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingConfirmation()));
                saveIncompleteBooking();
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


  Widget _buildAdditionalServices(BuildContext context, double companyPrice) {
    return Row(
      children: [
        Row(
          children: [
            Checkbox(
              value: _smsConfirmationSelected,
              onChanged: (bool? value) {
                setState(() {
                  _smsConfirmationSelected = value ?? false;
                  _updateTotalPrice();
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sms Confirmation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '£${smsFees.toStringAsFixed(2)}', // Ensures two decimal places
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 16), // Space between items
        Row(
          children: [
            Checkbox(
              value: _cancellationCoverSelected,
              onChanged: (bool? value) {
                setState(() {
                  _cancellationCoverSelected = value ?? false;
                  _updateTotalPrice();
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancellation Cover',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '£${cancellationFees.toStringAsFixed(2)}', // Correct price display
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> saveCardAndMakePayment(BuildContext context, String price) async {
    try {
      paymentIntent = await createPaymentIntent(price, 'GBP');

      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }

      String paymentIntentId = paymentIntent!['id'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          googlePay: const PaymentSheetGooglePay(
            testEnv: false,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
        ),
      );

      await displayPaymentSheet(context, price, paymentIntentId);

    } catch (e) {
      //print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> displayPaymentSheet(BuildContext context, String price, String paymentIntentId) async {
    try {
      await Stripe.instance.presentPaymentSheet();
    // Call postBookingData after successful payment
      await postBookingData(price, paymentIntentId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );

  
      paymentIntent = null;
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled")),
      );
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount) * 100).round().toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var secretKey = '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';
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        //print("Stripe API Error: ${response.body}");
        return null;
      }
    } catch (err) {
      //print('Error: ${err.toString()}');
      return null;
    }
  }

  Future<void> postBookingData(String price, String paymentIntentId) async {
    final url = Uri.parse('https://holidayscarparking.uk/api/booking');

    Map<String, String> bookingData = {
      'referenceNo': '$savedReferenceNo',
      'title': title,
      'first_name': firstName,
      'last_name': lastName,
      'email': '${user?['email']}',
      'contactno': phoneNumber,
      'deprTerminal': deprTerminal,
      'deptFlight': '$DepartureFlightNo',
      'returnTerminal': returnTerminal,
      'returnFlight': '$ArrivalFlightNo',
      'model': model,
      'color': color,
      'make': make,
      'registration': registration,
      'payment_status': 'success',
      'booking_amount': '$bookingPrice',
      'cancelfee': _cancellationCoverSelected ? '1.99' : '0.00',
      'smsfee': _smsConfirmationSelected ? '1.99' : '0.00',
      'booking_fee': '$bookingFees',
      'discount_amount': '6.52',
      'total_amount': price,
      'intent_id': paymentIntentId, // Fixed intent ID issue
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
        _notificationService.showNotification('$savedReferenceNo');
        Navigator.pushNamed(
          context,
          '/PaymentConfirm',
          arguments: {
            'company': company,
            'startDate': startDate,
            'endDate': endDate,
            'startTime': startTime,
            'endTime': endTime,
            'totalPrice': totalPrice,
            'referenceNo': '$savedReferenceNo',
          },
        );
      } else {
      }
    } catch (e) {
    }
  }


  Future<void> saveIncompleteBooking( ) async {
    DateFormat format = DateFormat("EEE, dd MMM yyyy");
    DateTime parsedStartDate = format.parse(startDate);
    DateTime parsedEndDate = format.parse(endDate);

    String formattedStartDate = DateFormat('yyyy-MM-dd').format(parsedStartDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(parsedEndDate);
    final url = Uri.parse('https://holidayscarparking.uk/api/saveIncompleteBooking');
    final response = await http.post(
      url,
      body: {
        'title': title,
        'first_name': firstName,
        'last_name': lastName,
        'email': '${user?['email']}',
        'contactno': phoneNumber,
        'parking_type': '${company['parking_type']}',
        'drop_date': formattedStartDate,
        'drop_time': '$startTime',
        'pick_date': formattedEndDate,
        'pick_time': '$endTime',
        'total_days': '$totalDays',
        'airport_id': '$airportId',
        'product_id': '${company['companyID']}',
        'product_code': '${company['product_code']}',
        'park_api': '${company['park_api']}',
        'booking_amount': '$bookingPrice',
        'booking_fee': '$bookingFees',
        'discount_amount': '4.29',
        'total_amount': '${bookingPrice + 1.99}',
        'promo': 'HCP-APP-OXT78U',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        savedReferenceNo = responseData['booking']['referenceNo']; // Store reference number
        ////print('Reference No: $responseData');
      }
      // ('Booking successful: ${response.body}');


    } else {
      ////print('Failed to book: ${response.reasonPhrase}');
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
                      autofocus: false,
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
                        onPressed: () async {
                          Navigator.maybePop(context);
                          await  saveCardAndMakePayment(context, totalPrice.toString());
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

  double calculateTotalFees() {
    double total = 0.0;
    if (_smsConfirmationSelected) {
      total += smsFees;
    }
    if (_cancellationCoverSelected) {
      total += cancellationFees;
    }
    // Assuming booking fees are always applied
    total += bookingFees;
    return total;
  }

  void _updateTotalPrice() {
    setState(() {
      totalPrice = bookingPrice + calculateTotalFees();
    });
  }
}
