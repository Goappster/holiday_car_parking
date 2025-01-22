import 'package:flutter/material.dart';

class Booking {
  final String title;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double payment;

  Booking({
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.payment,
  });
}

class MyBookingsScreen extends StatelessWidget {
  final List<Booking> bookings = [
    Booking(
      title: 'Purple Express Charge',
      location: 'Marina Mall',
      startDate: DateTime(2024, 11, 21, 9, 0),
      endDate: DateTime(2024, 12, 29, 4, 0),
      payment: 35.41,
    ),
  ];
  MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Resent Booking'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset('assets/images/purple.png'), // Add your image asset
                    title: Text(booking.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.location),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 5),
                            Text('${booking.startDate.day}/${booking.startDate.month}/${booking.startDate.year} ${booking.startDate.hour}:${booking.startDate.minute}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 5),
                            Text('${booking.endDate.day}/${booking.endDate.month}/${booking.endDate.year} ${booking.endDate.hour}:${booking.endDate.minute}'),
                          ],
                        ),
                        Text('Payment Made: £${booking.payment.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: const Icon(Icons.more_vert),
                  ),
                );
              },
            ),
            const Center(child: Text('Create New Ticket')), // Content for Create New Ticket tab
          ],
        ),
      ),
    );
  }
}