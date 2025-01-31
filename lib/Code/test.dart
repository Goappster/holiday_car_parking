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
  final int staticAirportId = 20; // Static airport ID
  List<Map<String, dynamic>> terminals = [];
  int? selectedDropoffTerminalId;
  int? selectedPickupTerminalId;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              // Drop-off Terminal Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Drop-off Terminal',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(50),
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
                  //print('Selected Drop-off Terminal ID: $selectedId');
                },
                value: selectedDropoffTerminalId,
                hint: Text('Choose Drop-off Terminal'),
                isExpanded: true,
              ),
              SizedBox(height: 16), // Spacing
              // Pickup Terminal Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Pickup Terminal',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(50),
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
                  //print('Selected Pickup Terminal ID: $selectedId');
                },
                value: selectedPickupTerminalId,
                hint: Text('Choose Pickup Terminal'),
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
