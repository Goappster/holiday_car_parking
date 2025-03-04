import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/dio.dart';
import '../../utils/UiHelper.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {

  Map<String, dynamic>? user;
  List<Map<String, dynamic>> bookings = [];
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
      await loadBookings();
    } else {
      setState(() => isLoading = false);
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

  Future<void> loadBookings() async {
    if (user == null || user?['id'] == null) return;

    setState(() => isLoading = true);

    try {
      final response = await _apiService.postRequest('/bookingHistory', {
        "user_id": user!['id'].toString(),
      });

      setState(() {
        if (response != null && response.data['status'] == 'success') {
          bookings = List<Map<String, dynamic>>.from(response.data['data']);
        } else {
          bookings = [];
        }
      });
    } catch (e) {
      setState(() => bookings = []);
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child:  Scaffold(
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
              onRefresh: loadBookings,
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return GestureDetector(
                    onTap: () { Navigator.pushNamed(context, '/PaymentReceipt', arguments: booking); },
                    child: BookingCard(booking: booking),
                  );
                },
              ),
            ),
            Center(child: Text('No bookings found')),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                            image: NetworkImage(booking['company_logo'] ?? ''),
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
                            booking['company_name'] ?? 'Unknown Company',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(booking['airport_name'] ?? 'Unknown Airport', style: TextStyle(color: Colors.grey)),
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
                          _buildDateInfo('assets/map_blue.svg', booking['return_date'], Colors.blue.withOpacity(0.2)),
                          _buildDateInfo('assets/map.svg', booking['departure_date'], Colors.green.withOpacity(0.2)),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Payment Made: ',
                          children: [
                            TextSpan(
                              text: '£${booking['total_amount'] ?? '0.00'}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
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

  Widget _buildDateInfo(String assetPath, String? date, Color bgColor) {
    DateTime? parsedDate;
    if (date != null) {
      try {
        parsedDate = DateTime.parse(date);
      } catch (e) {
        parsedDate = null;
      }
    }
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: bgColor),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset(assetPath),
          ),
        ),
        SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parsedDate != null ? DateFormat('dd/MM/yyyy').format(parsedDate) : 'Unknown Date'),
            Text(parsedDate != null ? DateFormat('h:mm a').format(parsedDate) : 'Unknown Time', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}