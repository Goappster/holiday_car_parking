import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart'as Material;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http ;

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
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);
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
    final totalPrice = args['totalPrice'];
    final cancellationCover = args['cancellationCover'];
    final ConfirmationSelected = args['ConfirmationSelected'];


    // String priceString = company['price']; double.parse(priceString)
    double price = totalPrice + 1.99;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCompanyLogo(company),
                  const SizedBox(width: 10),
                  _buildCompanyDetails(company),
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
              buildDetailRow('Booking Price', '£${totalPrice.toStringAsFixed(2)}'),
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
                    '£${price.toStringAsFixed(2)}',
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
                          _buildCompanyLogo(company),
                          const SizedBox(width: 10),
                          _buildCompanyDetails(company),
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
                              Icons.attach_money, 'Booking Price', '£${totalPrice.toStringAsFixed(2)}'),
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
                  _showPaymentOptions(context, price.toString(), company, airportId.toString(), startDate, endDate, startTime, endTime, totalDays.toString(), totalPrice.toString(), price);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingConfirmation()));
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

  Widget _buildCompanyLogo(Map<String, dynamic> company) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(3)),
      child: company['park_api'] == 'DB'
          ? CachedNetworkImage(imageUrl: 'https://airportparkbooking.uk/storage/${company['logo']}',
              height: 40, width: 60, fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : company['park_api'] == 'holiday'
              ? CachedNetworkImage(
                  imageUrl: company['logo'],
                  height: 40,
                  width: 60,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : null,
    );
  }

  Widget _buildCompanyDetails(Map<String, dynamic> company) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${company['name']}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text('${company['parking_type']}'),
        ],
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, String price, Map<String, dynamic> company, String airportId, String startDate, String endDate, String startTime, String endTime, String totalDays, String totalPrice, double priceTotal ) {
    final List<Map<String, dynamic>> chipData = [
      {"label": "Visa", "image": "assets/images/visa_logo.png"},
      {"label": "PayPal", "image": "assets/images/paypal_logo.png"},
      {"label": "Apple Pay", "image": "assets/images/applepay_logo.png"},
    ];

    showModalBottomSheet(
      context: context,
      isDismissible: false,
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
                            color: isSelected ? Theme.of(context).primaryColor: Colors.transparent,
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
                      return _visaLayout(price, company, airportId, startDate, endDate, startTime, endTime, totalDays, totalPrice, priceTotal);
                    }
                  }
                  return Container(); // Empty container until a selection is made
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _applePayLayout() {
    return  const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Coming soon!!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text("Coming soon!!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // You can add PayPal-specific widgets here.
        ],
      ),
    );
  }

  Widget _visaLayout(String price, Map<String, dynamic> company, String airportId, String startDate, String endDate, String startTime, String endTime, String totalDays, String totalPrice, double priceTotal) {
    return  SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enter Card Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),   InkWell(
                onTap: () async {
                  Navigator.maybePop(context);
                  await saveCardAndMakePayment(context, price);
                },
                child: Text(
                  '*Autofill Link',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // CardField(
          //   onCardChanged: (cardDetails) {
          //     setState(() {
          //       // _cardDetails = cardDetails! as CardDetails;
          //     });
          //   },
          // ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _buildButton(context, 'Cancel', Theme.of(context).colorScheme.surface, Colors.red),
              // _buildButton(context, 'Confirm', Colors.red, Colors.white),
              ElevatedButton(
                onPressed: () async {
                  Navigator.maybePop(context);
                  // postBookingData('100');
                 saveIncompleteBooking( company, airportId, startDate, endDate, startTime, endTime,totalDays,totalPrice,priceTotal);

                  // print('$airportId $startDate $startTime $endDate $endTime $totalDays $totalPrice ${priceTotal + 1.99}',);

                },
                style: ElevatedButton.styleFrom(
                  // minimumSize: const Size( w48),   minimumSize: const Size( w48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'text',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> saveCardAndMakePayment(BuildContext context, String price) async {
    try {
      var paymentIntent = await createPaymentIntent(price, 'GBP');
      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Holiday Car Parking',
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
        ),
      );
      await displayPaymentSheet(context);
    } catch (e) {
      print("Payment Exception: $e");
    }
  }

  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
    } on StripeException catch (e) {
      print('Stripe Error: $e');
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
      var secretKey = 'sk_test_51OvKOKIpEtljCntg1FlJgg8lqldMDCAEZscX3lGtppD7LId1gV0aBIrxDmpGwAKVZv8RDXXm4RmTNxMlrOUocTVh00tASgVVjc';
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey', // Store securely
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> paymentIntentResponse = jsonDecode(response.body);
        String paymentIntentId = paymentIntentResponse['id']; // Payment intent ID
        String paymentStatus = paymentIntentResponse['status'];
        print('PaymentId:$paymentIntentId paymentStatus:$paymentStatus');
        String price = amount;
        postBookingData(price);
        return jsonDecode(response.body);
      } else {
        print('Stripe Error: ${response.body}');
        return null;
      }
    } catch (err) {
      print('HTTP Error: ${err.toString()}');
      return null;
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
  Future<void> postBookingData(String price) async {
    final url = Uri.parse('https://holidayscarparking.uk/api/booking');
    final response = await http.post(
      url,
      body: {
        'referenceNo': 'HCP-04241127820',
        'title': '${user?['title']}',
        'first_name': '${user?['first_name']}',
        'last_name': '${user?['last_name']}',
        'email': '${user?['email']}',
        'contactno': '${user?['phone_number']}',
        'deprTerminal': '457',
        'deptFlight': 'ASD124',
        'returnTerminal': '457',
        'returnFlight': 'ASD125',
        'model': 'A5',
        'color': 'White',
        'make': 'Audi',
        'registration': 'ASX 075',
        'payment_status': 'success',
        'booking_amount': '60.99',
        'cancelfee': '4.99',
        'smsfee': '1.99',
        'booking_fee': '1.99',
        'discount_amount': '6.52',
        'total_amount': price,
        'intent_id': 'pi_3QPVaHIpEtljCntg2iTKEAFd',
      },
    );
    if (response.statusCode == 200) {
      print('Booking successful: ${response.body}');
    } else {
      print('Failed to book: ${response.reasonPhrase}');
    }
  }

  Future<void> saveIncompleteBooking(Map<String, dynamic> company, String airportId, String startDate, String endDate, String startTime, String endTime, String totalDays, String totalPrice, double priceTotal) async {
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
        'drop_date': startDate,
        'drop_time': startDate,
        'pick_date': endDate,
        'pick_time': endTime,
        'total_days': totalDays,
        'airport_id': airportId,
        'product_id': '${company['companyID']}',
        'product_code': '${company['product_code']}',
        'park_api': '${company['park_api']}',
        'booking_amount': totalPrice,
        'booking_fee': '1.99',
        'discount_amount': '4.29',
        'total_amount': '${priceTotal + 1.99}',
        'promo': 'HCP-APP-OXT78U',
      },
    );
    if (response.statusCode == 200) {
      print('Booking successful: ${response.body}');
    } else {
      print('Failed to book: ${response.reasonPhrase}');
    }
  }
}
