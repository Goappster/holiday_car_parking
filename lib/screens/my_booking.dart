import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holidayscar/screens/support_ticket.dart';
import 'package:http/http.dart' as http;
import 'package:holidayscar/models/booking.dart';
import 'package:intl/intl.dart';

class BookingDatabase {
  static final BookingDatabase instance = BookingDatabase._init();

  BookingDatabase._init();

  Future<List<Booking>> getBookings() async {
    final response = await http.post(
      Uri.parse('https://holidayscarparking.uk/api/bookingHistory'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': 890}),
    );

    if (response.statusCode == 200) {
      //print(response.body);
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> bookings = [];
  bool isLoading = true;

  Future<void> fetchBookings() async {
    try {
      final data = await BookingDatabase.instance.getBookings();
      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      //print('Error fetching bookings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold),),
          bottom: TabBar(
            dividerHeight: 0,
            labelColor: Colors.white, 
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).primaryColor, 
            ),
            tabs: [
              Tab(text: '              Active              '),
              Tab(text: '          All Booking             '),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : TabBarView(
          children: [
            bookings.isEmpty
                ? Center(child: Text('No active bookings'))
                : RefreshIndicator(
              onRefresh: fetchBookings,
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/PaymentReceipt',
                          arguments: {
                            'airportName': booking.airportName,
                            'departureDate': booking.departureDate,
                            'returnDate': booking.returnDate,
                            'totalPrice': booking.totalAmount.toString(),
                            'ReferenceNo': booking.referenceNo,
                            'companyName': booking.companyName,
                            'companyLogo': booking.companyLogo,
                            'no_of_days': booking.numberOfDays.toString(),
                          },
                        );
                      },
                      child: BookingCard(booking: booking));
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16, ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(booking.companyLogo),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.companyName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(booking.airportName, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),


                  SizedBox(height: 8),
                  Column(
                    children: [
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
                                    color: const Color(0xFF1D9DD9)
                                        .withOpacity(0.20)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    'assets/map_blue.svg',
                                    // semanticsLabel: 'My SVG Image',
                                    // height: 10,
                                    // width: 10,
                                    // fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(booking.returnDate)),
                                  Text(
                                    DateFormat('h:mm a').format(booking.returnDate),
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
                                    color: const Color(0xFF33D91D)
                                        .withOpacity(0.20)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    'assets/map.svg',
                                    // semanticsLabel: 'My SVG Image',
                                    // height: 10,
                                    // width: 10,
                                    // fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(booking.departureDate)),
                                  Text(
                                    DateFormat('h:mm a').format(booking.departureDate),
                                    style: TextStyle(color: Colors.grey),  // Change the color here
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),



                      Text.rich(
                        TextSpan(
                          text: 'Payment Made: ',
                          children: [
                            TextSpan(
                              text: '£${booking.totalAmount}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor

                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
