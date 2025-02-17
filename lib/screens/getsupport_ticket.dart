import 'package:flutter/material.dart';
import 'dart:convert';  // To decode JSON
import 'package:http/http.dart' as http;

import '../routes.dart';
import 'chat_ui.dart';

// void main() {
//   runApp(MaterialApp(home: SupportTicketScreen()));
// }

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  _SupportTicketScreenState createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  // Function to fetch tickets from the API
  Future<void> fetchTickets() async {
    final response = await http.post(
      Uri.parse('https://holidayscarparking.uk/api/getSupportTicketsList'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': 890,  // Adjust this value based on the logged-in user or another source of the user ID
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['success']) {
        setState(() {
          tickets = responseData['data'];  // Update the tickets list with the response data
        });
      }
    } else {
      //print('Error: ${response.statusCode}');
      //print('Response body: ${response.body}');
      //print('Failed to fetch tickets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text('Support Tickets')),
      body: tickets.isEmpty
          ? Center(child: CircularProgressIndicator())  // Loading indicator
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          var ticket = tickets[index];
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailsPage(ticketRef: '${ticket['ticket_id']}'),
                  ),
                );
              },
              child: CustomTicketCard(ticket: ticket));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Create Ticket Screen when the FAB is pressed
          Navigator.pushNamed(context, AppRoutes.createSupportTicket);
        },
        tooltip: 'Create Ticket',
        child: Icon(Icons.add),
      ),
    );
  }
}

class CustomTicketCard extends StatelessWidget {
  final dynamic ticket;

  CustomTicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket ID: ${ticket['ticket_id']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Subject: ${ticket['title']}',  // Corrected from 'subject' to 'title'
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${ticket['status']}',
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              'Created: ${ticket['date']}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
