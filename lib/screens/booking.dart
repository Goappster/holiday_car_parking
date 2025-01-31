import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/models/vehicle.dart';
import 'package:holidayscar/screens/vehicle_management.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/booking_api.dart';
import '../widgets/text.dart';

class BookingScreen extends StatefulWidget {

  final dynamic company;
  final Vehicle? vehicle;
  final String totalDays;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String airportId;


  const BookingScreen({super.key,
    required this.company,
    required this.totalDays,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime, this.vehicle, required this.airportId,

  });

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

  double smsFees = 1.99;
  double cancellationFees = 1.99;
  late double totalPrice;

  bool _smsConfirmationSelected = false;
  bool _cancellationCoverSelected = false;

  void _updateTotalPrice() {
    double parsedPrice = double.tryParse(widget.company['price'].toString()) ?? 0.0;

    double updatedTotal = parsedPrice;
    if (_smsConfirmationSelected) updatedTotal += smsFees;
    if (_cancellationCoverSelected) updatedTotal += cancellationFees;

    setState(() {
      totalPrice = updatedTotal;
    });
  }



  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _initializeDefaultVehicle();
    _updateTotalPrice();
  }

  // void _initializeDefaultVehicle() async {
  //   List vehiclesData = await fetchVehiclesByCustomer('${user?['id']}'); // Replace with actual user ID
  //   List<Vehicle> vehicles = vehiclesData.map((data) => Vehicle.fromMap(data)).toList();
  //
  //   if (vehicles.isNotEmpty) {
  //     setState(() {
  //       _selectedVehicle = vehicles[0]; // Set the first vehicle as the default
  //     });
  //   }
  // }
  String? token;
  Map<String, dynamic>? user;
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? ''; // Default to an empty string if null
      String? userData = prefs.getString('user');
      if (userData != null) {
        try {
          user = json.decode(userData);
        } catch (e) {
          //print("Failed to parse user data: $e");
          user = null;
        }
      }
    });
  }

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double companyPrice = double.tryParse(widget.company['price'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  const Text('Booking'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
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
                        : const Text('No vehicle selected.'),
                    _buildAddVehicleButton(context),
                    _buildSectionTitle('Explore Additional Services'),
                    _buildAdditionalServices(context, companyPrice),
                    SizedBox(height: 16,),
                    _buildContinueButton(context, _selectedVehicle),
                  ],
                ),
              ),
            ),
          ),

          // ElevatedButton(
          //   onPressed: () {
          //     saveBookingDetails();
          //   },
          //   child: Text('Add Data'),
          // ),
        ],
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611759.jpg?t=st=1737462976~exp=1737466576~hmac=bb7f1ed6b30ebe44da413b5b2cc15fa51ea4e9e3affc6444ac96799a26db1911&w=740'), // Replace with actual image asset
          ),
          title:  Text('Mr, ${user?['first_name']} ${user?['last_name']}'),
          subtitle: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 4),
                  // Text('${user?['email']}', style: Theme.of(context).textTheme.labelSmall,),
                  AutoSizeText(
                    '${user?['email']}',
                    presetFontSizes: [12, 20, 14],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('${user?['phone_number']}'),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showUserInformation(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFlightDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(
            'Do you have Flight details?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'We will set your Flight details to be confirmed if you select. You can add these details later on by contacting support desk.',
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
        leading: Image.asset('assets/images/car.png'),
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
                Text('Model: ${vehicle.model}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _selectVehicle(context);
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
            //print('Selected Vehicle: $_selectedVehicle');
            _selectVehicle(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red), // Border color
          ),
          child: const Text('+ Select Vehicle'),
        ),
      ),
    );
  }

  Future<void> _selectVehicle(BuildContext context) async {
    // Fetch vehicles from your data source
    List vehiclesData = await fetchVehiclesByCustomer('${user?['id']}'); // Replace with actual user ID
    List<Vehicle> vehicles = vehiclesData.map((data) => Vehicle.fromMap(data)).toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Vehicle'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return ListTile(
                  title: Text('Make: ${vehicle.make}'),
                  subtitle: Text('Model: ${vehicle.model}, Color: ${vehicle.color}, registration: ${vehicle.registration}'),
                  onTap: () {
                    _onVehicleSelected(vehicle);
                    // Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    ).then((selectedVehicle) {
      if (selectedVehicle != null) {
        _onVehicleSelected(selectedVehicle);
      }
    });
  }

  Widget _buildAdditionalServices(BuildContext context, double companyPrice) {
    return Row(
      children: [
        Row(
          children: [
            Checkbox(
              value: _smsConfirmationSelected,
              onChanged: (bool? value) {
                setState(() {
                  _smsConfirmationSelected = value ?? false;
                  _updateTotalPrice();
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sms Confirmation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '£${smsFees.toStringAsFixed(2)}', // Ensures two decimal places
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 16), // Space between items
        Row(
          children: [
            Checkbox(
              value: _cancellationCoverSelected,
              onChanged: (bool? value) {
                setState(() {
                  _cancellationCoverSelected = value ?? false;
                  _updateTotalPrice();
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancellation Cover',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '£${cancellationFees.toStringAsFixed(2)}', // Correct price display
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, Vehicle? vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            if (vehicle != null) {
              Navigator.pushNamed(
                context,
                '/BookingDetails',
                arguments: {
                  'company': widget.company,
                  'Email': _flightName,
                  'startDate': widget.startDate,
                  'endDate': widget.endDate,
                  'startTime': widget.startTime,
                  'endTime': widget.endTime,
                  'totalDays': widget.totalDays,
                  'totalPrice': totalPrice,
                  'AirportId': widget.airportId,
                  'cancellationCover': _cancellationCoverSelected ? 1.99 : null,
                  'ConfirmationSelected': _smsConfirmationSelected ? 1.99 : null,
                  'registration': vehicle!.registration!,
                  'make': vehicle.make!,
                  'color': vehicle.color!,
                  'model': vehicle.model!,
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a vehicle to continue.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text('Continue'),
        )
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
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Title',
                          hintText: 'Mr/Ms',
                          obscureText: false,
                          icon: Icons.person,
                          controller: emailController,
                        ),
                      ),
                      const SizedBox(width: 10), // Space between the fields
                      Expanded(
                        child: CustomTextField(
                          label: 'First Name',
                          hintText: 'First Name',
                          obscureText: false,
                          icon: Icons.person,
                          controller: emailController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Last Name',
                    hintText: 'Last Name',
                    obscureText: false,
                    icon: Icons.person,
                    controller: emailController,
                  ),
                  const SizedBox(height: 10),
                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Email',
                    obscureText: false,
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  // const SizedBox(height: 20),
                  const SizedBox(height: 10),
                  // Phone Number Field
                  CustomTextField(
                    label: 'Phone Number',
                    hintText: 'Phone Number',
                    obscureText: false,
                    icon: Icons.phone,
                    controller: emailController,
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

  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {
        // saveBookingDetails();
       Navigator.pushNamed(context, 'BookingDetails',);
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