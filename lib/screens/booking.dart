import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:holidayscar/models/vehicle.dart';
import 'package:holidayscar/screens/vehicle_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  BookingScreen({super.key, required this.company});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _hasTravelDetails = false;
  String? _flightNumber;
  String? _flightName;
  String _departureTime = '';
  String _arrivalTime = '';
  Vehicle? _selectedVehicle;
  String? token;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      String? userData = prefs.getString('user');
      if (userData != null) {
        user = json.decode(userData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Booking'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Your Personal Information'),
              _buildPersonalInfoCard(),
              _buildSectionTitle('Flight Details'),
              _buildFlightDetails(context),
              _buildSectionTitle('Vehicle Details'),
              _selectedVehicle != null
                  ? _buildVehicleDetails(context, _selectedVehicle!)
                  : const Text('No vehicle selected'),
              _buildAddVehicleButton(context),
              _buildSectionTitle('Explore Additional Services'),
              _buildAdditionalServices(context),
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage('https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611759.jpg?t=st=1737462976~exp=1737466576~hmac=bb7f1ed6b30ebe44da413b5b2cc15fa51ea4e9e3affc6444ac96799a26db1911&w=740'), // Replace with actual image asset
        ),
        title:  Text('Mr, ${user!['first_name']} ${user!['last_name']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email, color: Colors.blue),
                const SizedBox(width: 4),
                Text('${user!['email']}'),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.phone, color: Colors.green),
                SizedBox(width: 4),
                Text('0900-7860123'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildFlightDetails(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Do you have travel details?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'We will set your Travel details to be confirmed if you select. You can add these details later on by contacting support desk.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: _hasTravelDetails,
          onChanged: (bool value) {
            setState(() {
              _hasTravelDetails = value;
            });
            if (value) {
              _showFlightDetailsForm(context);
            }
          },
        ),
        // if (_hasTravelDetails && _flightNumber.isNotEmpty) ...[
        //   Text('Flight Number: $_flightNumber'),
        //   Text('Flight Name: $_flightName'),
        //   Text('Departure Time: $_departureTime'),
        //   Text('Arrival Time: $_arrivalTime'),
        // ],
      ],
    );
  }

  void _showFlightDetailsForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Flight Number'),
                onChanged: (value) {
                  setState(() {
                    _flightNumber = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Flight Name'),
                onChanged: (value) {
                  setState(() {
                    _flightName = value;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Departure Time'),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _departureTime = picked.format(context);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Arrival Time'),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _arrivalTime = picked.format(context);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetails(BuildContext context, Vehicle vehicle) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).cardColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Image.asset(vehicle.imageUrl),
        title: Text(vehicle.make),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.color_lens, color: Colors.blue),
                const SizedBox(width: 4),
                Text('Color: ${vehicle.color}'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.green),
                const SizedBox(width: 4),
                Text('Model No: ${vehicle.model}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Handle edit action
          },
        ),
      ),
    );
  }

  void _onVehicleSelected(Vehicle vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
    Navigator.pop(context);
  }

  Widget _buildAddVehicleButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleManagementScreen(
                  vehicles: [
                    Vehicle(
                      imageUrl: 'assets/images/car.png',
                      make: 'Japan Motors',
                      registration: 'AB-123',
                      color: 'Cherry Black',
                      model: '2019',
                    ),
                    Vehicle(
                      imageUrl: 'assets/images/car.png',
                      make: 'China Motors',
                      registration: 'BA-804',
                      color: 'Dark Gray',
                      model: '2020',
                    ),
                  ],
                  onVehicleSelected: _onVehicleSelected,
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red), // Border color
          ),
          child: const Text('+ Add Vehicle'),
        ),
      ),
    );
  }

  Widget _buildAdditionalServices(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (bool? value) {},
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sms Confirmation', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const Text('£1.99', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(width: 16), // Space between items
        Row(
          children: [
            Checkbox(
              value: true,
              onChanged: (bool? value) {},
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cancellation Cover', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const Text('£4.99', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/BookingDetails',
            arguments: {
              'company': widget.company,
              'Email': _flightName,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('continue'),
      ),
    );
  }

  void _showUserInformation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.70,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Add Personal Information', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField('Title', 'Mr', context),
                  _buildTextField('First Name', 'Alex', context),
                  _buildTextField('Last Name', 'Carry', context),
                  _buildTextField('Passengers', '03', context),
                  _buildTextField('Mobile Number', '0900-78601', context),
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
                      _buildButton(context, 'Save Information', Colors.red, Colors.white),
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

  Widget _buildTextField(String label, String initialValue, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          labelStyle: const TextStyle(fontSize: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            // borderSide: BorderSide.none,
          ),
        ),
        controller: TextEditingController(text: initialValue),
        // readOnly: true,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'BookingDetails',

        arguments: {
          ''

        }

        );
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
                  _buildTextField('Vehicle Registration', 'PK-20', context),
                  _buildTextField('Vehicle Make', 'Alex', context),
                  _buildTextField('Vehicle Color', 'Carry', context),
                  _buildTextField('Vehicle Model', '03', context),
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
                      _buildButton(context, 'Save Information', Colors.red, Colors.white),
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
}