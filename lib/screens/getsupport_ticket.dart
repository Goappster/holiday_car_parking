import 'package:flutter/material.dart';
import 'dart:convert';  // To decode JSON
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/connectivity_provider.dart';
import '../routes.dart';
import '../utils/UiHelper.dart';
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
  Map<String, dynamic>? user;
  bool _isLoading = true; // Track loading state


  @override
  void initState() {
    super.initState();
    _loadUserData();  // Only load user data on initialization
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user');

    if (userData != null) {
      try {
        setState(() {
          user = json.decode(userData);  // Parse user data
          _isLoading = true;  // Indicate that data is being loaded
        });
        await fetchTickets();  // Fetch tickets once user data is available
      } catch (e) {
        setState(() {
          user = null;
          _isLoading = false; // Stop loading if user data decoding fails
        });
      }
    } else {
      setState(() {
        user = null;  // No user data found
        _isLoading = false;  // Stop loading if no user data
      });
    }
  }

  Future<void> fetchTickets() async {
    if (user == null) {
      setState(() {
        _isLoading = false;  // Stop loading if no user is logged in
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://holidayscarparking.uk/api/getSupportTicketsList'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user!['id'],  // Ensure that the user ID is correct
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            tickets = responseData['data'];  // Update tickets with response data
            _isLoading = false;  // Stop loading when the data is fetched
          });
        } else {
          setState(() {
            tickets = [];
            _isLoading = false;  // Stop loading in case of error in the response
          });
        }
      } else {
        setState(() {
          tickets = [];
          _isLoading = false;  // Stop loading if the API call fails
        });
      }
    } catch (e) {
      setState(() {
        tickets = [];
        _isLoading = false;  // Stop loading in case of error (network issues, etc.)
      });
    }
  }

  Future<void> _onRefresh() async {
    // Trigger the refresh action
    setState(() {
      _isLoading = true; // Set loading to true while refreshing data
    });
    await fetchTickets(); // Fetch tickets again when the user pulls to refresh
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('Support Tickets'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(), // Show loading spinner while fetching data
        )
            : tickets.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No tickets found.',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ],
          ),
        )
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
              child: CustomTicketCard(ticket: ticket),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the "Create New Ticket" screen
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
