import 'package:flutter/material.dart';

import '../services/get_airports.dart';


void main() {
  runApp(AirportApp());
}

class AirportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AirportDropdown(),
    );
  }
}

class AirportDropdown extends StatefulWidget {
  @override
  _AirportDropdownState createState() => _AirportDropdownState();
}

class _AirportDropdownState extends State<AirportDropdown> {
  late Future<List<Map<String, dynamic>>> _airportData;

  @override
  void initState() {
    super.initState();
    _airportData = GetAirports.fetchAirports(); // Fetch data only once
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airport Dropdown'),
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _airportData, // Use the stored future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No airports available');
            } else {
              final airports = snapshot.data!;
              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Airport',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                items: airports.map((airport) {
                  return DropdownMenuItem<int>(
                    value: airport['id'],
                    child: Text(airport['name']),
                  );
                }).toList(),
                onChanged: (selectedId) {
                  //print('Selected Airport ID: $selectedId');
                },
              );
            }
          },
        ),
      ),
    );
  }
}