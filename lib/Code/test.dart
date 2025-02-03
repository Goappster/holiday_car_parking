import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(TerminalDropdown());
}


class TerminalDropdown extends StatefulWidget {
  @override
  _TerminalDropdownState createState() => _TerminalDropdownState();
}

class _TerminalDropdownState extends State<TerminalDropdown> {


  @override
  void initState() {
    super.initState();
    fetchTerminals(staticAirportId); // Fetch terminals when the widget is initialized
  }

  Future<void> fetchTerminals(int airportId) async {
    final response = await http.post(
      Uri.parse('https://holidayscarparking.uk/api/airportTerminals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'airport_id': airportId}),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      setState(() {
        terminals = data.map<Map<String, dynamic>>((terminal) {
          return {
            'id': terminal['id'],
            'name': terminal['name'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load terminals');
    }
  }
  final int staticAirportId = 20; // Static airport ID
  List<Map<String, dynamic>> terminals = [];
  int? selectedDropoffTerminalId;
  int? selectedPickupTerminalId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row containing both Dropdown buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Drop-off Terminal Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0), // Space between dropdowns
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drop-off Terminal', // Text label

                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: terminals.map((terminal) {
                                return DropdownMenuItem<int>(
                                  value: terminal['id'],
                                  child: Text(terminal['name']),
                                );
                              }).toList(),
                              onChanged: (selectedId) {
                                setState(() {
                                  selectedDropoffTerminalId = selectedId;
                                });
                              },
                              value: selectedDropoffTerminalId,
                              hint: Text('Choose Drop-off Terminal'),
                              isExpanded: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Pickup Terminal Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0), // Space between dropdowns
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Terminal', // Text label

                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: terminals.map((terminal) {
                                return DropdownMenuItem<int>(
                                  value: terminal['id'],
                                  child: Text(terminal['name']),
                                );
                              }).toList(),
                              onChanged: (selectedId) {
                                setState(() {
                                  selectedPickupTerminalId = selectedId;
                                });
                              },
                              value: selectedPickupTerminalId,
                              hint: Text('Choose Pickup Terminal'),
                              isExpanded: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
