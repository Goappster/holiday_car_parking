import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



Future<Map<String, dynamic>> fetchTicketDetails(String ticketRef) async {
  final response = await http.post(
    Uri.parse('https://holidayscarparking.uk/api/getSupportTicketsView'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'ticket_ref': ticketRef}),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load ticket details');
  }
}

class TicketDetailsPage extends StatefulWidget {
  final String ticketRef;
  const TicketDetailsPage({super.key, required this.ticketRef});

  @override
  _TicketDetailsPageState createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  late Future<Map<String, dynamic>> ticketData;

  @override
  void initState() {
    super.initState();
    ticketData = fetchTicketDetails(widget.ticketRef);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ticketData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final progress = data['data']['progress'];

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: progress.entries.map<Widget>((entry) {
                final messageData = entry.value;
                final isClient = messageData['reply_by'] == 'Client';
                return Column(
                  crossAxisAlignment: isClient ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    _buildChatBubble(
                      content: messageData['message'],
                      isSender: !isClient,
                    ),
                    Text(
                      'Time: ${messageData['replyingtime']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (messageData['attachment'] != null && messageData['attachment'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.network(
                          'https://holidayscarparking.uk/${messageData['attachment']}',
                          height: 200,
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('No Data Available'));
          }
        },
      ),
    );
  }

  Widget _buildChatBubble({
    required String content,
    required bool isSender,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSender ? Colors.blue[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the ticket details page with a sample ticket_ref
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailsPage(ticketRef: 'T-06022573'),
              ),
            );
          },
          child: const Text('View Ticket Details'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
