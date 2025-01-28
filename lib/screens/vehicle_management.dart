import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/vehicle.dart';
import '../widgets/text.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  _VehicleManagementScreenState createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  List<dynamic> _vehicles = [];
  bool _isLoading = true;
  Map<String, dynamic>? user;


  String? token;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _loadUserData();
  }


  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? ''; // Default to an empty string if null
      String? userData = prefs.getString('user');
      if (userData != null) {
        try {
          user = json.decode(userData);
        } catch (e) {
          print("Failed to parse user data: $e");
          user = null;
        }
      }
    });
  }

  Future<void> _fetchVehicles() async {
    try {
      List<dynamic> vehicles = await fetchVehiclesByCustomer('${user?['email']}');
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching vehicles: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchVehicles,
              child: ListView.builder(
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return Padding(
                    padding:  EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme
                                        .of(context)
                                        .primaryColor
                                        .withOpacity(0.20)
                                ),
                                child: Icon(MingCute.car_3_line, color: Theme
                                    .of(context)
                                    .primaryColor, size: 35,)
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicle['make']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${vehicle['registration']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Color(0xFF1D9DD9)
                                                  .withOpacity(0.20)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: SvgPicture.asset(
                                              'assets/color.svg',
                                              // semanticsLabel: 'My SVG Image',
                                              // height: 10,
                                              // width: 10,
                                              // fit: BoxFit.fill,
                                            ),
                                          ),
                                      ),
                                      SizedBox(width: 6),
                                      Column(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Color',style: Theme.of(context).textTheme.labelSmall ),
                                          SizedBox(width: 2),
                                          Text('${vehicle['color']}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Spacer(),
                                      SvgPicture.asset(
                                        'assets/model_no.svg',
                                        // semanticsLabel: 'My SVG Image',
                                        height: 30,
                                      ),
                                      SizedBox(width: 6),
                                      Column(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Model No',style: Theme.of(context).textTheme.labelSmall ),
                                          SizedBox(width: 2),
                                          Text('${vehicle['model']}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit action
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
       shape: const CircleBorder(),
        onPressed: () {
          _showVehicle(context);
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }



  void _showVehicle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.60,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Add Vehicle Details', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Vehicle Make',
                    hintText: 'Japan Motors',
                    obscureText: false,
                    icon: Icons.person,
                    controller: TextEditingController(),
                  ),
                  CustomTextField(
                    label: 'Vehicle Make',
                    hintText: 'Japan Motors',
                    obscureText: false,
                    icon: Icons.person,
                    controller: TextEditingController(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Vehicle Color',
                          hintText: 'Black',
                          obscureText: false,
                          icon: Icons.person,
                          controller: TextEditingController(),
                        ),
                      ),
                      const SizedBox(width: 10), // Space between the fields
                      Expanded(
                        child: CustomTextField(
                          label: 'Vehicle Model',
                          hintText: '2019',
                          obscureText: false,
                          icon: Icons.person,
                          controller: TextEditingController(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please enter your email address, first name, and last name to enable the mobile number field.',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(context, 'Cancel', Theme.of(context).colorScheme.surface, Colors.red),
                      _buildButton(context, 'Add Vehicle', Colors.red, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'BookingDetails');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: const Size(150, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.red),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

}

Future<List<dynamic>> fetchVehiclesByCustomer(String userId) async {
  final url = Uri.parse('https://holidayscarparking.uk/api/getVehiclesByCustomer');

  try {
    final response = await http.post(
      url,
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['success']) {
        return responseBody['vehicles'];
      } else {
        throw Exception('Failed to retrieve vehicles: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching vehicles: $e');
    return [];
  }
}

// Example usage:
// List<dynamic> vehicles = await fetchVehiclesByCustomer('890');
// print(vehicles);

class AddVehicleForm extends StatelessWidget {
  const AddVehicleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'Vehicle Registration'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Vehicle Make'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Vehicle Color'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Vehicle Model'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle add vehicle action
                },
                child: const Text('Add Vehicle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
