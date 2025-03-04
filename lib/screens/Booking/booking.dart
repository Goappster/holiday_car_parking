import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/models/vehicle.dart';
import 'package:holidayscar/routes.dart';
import 'package:holidayscar/screens/vehicle_management.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/booking_api.dart';
import '../../widgets/text.dart';
import 'package:http/http.dart' as http;

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
  void initState() {
    super.initState();
    _loadUserData();
    // _initializeDefaultVehicle();
    _updateTotalPrice();
    int? airportIdInt = int.tryParse(widget.airportId);
    fetchTerminals(airportIdInt!);
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
          selectedTitle = user?['title'];
          firstNameController.text = user?['first_name'];
          lastNameController.text = user?['last_name'];
          phoneNumberController.text = user?['phone_number'];

        } catch (e) {
          ////print("Failed to parse user data: $e");
          user = null;
        }
      }
    });
  }

  String? selectedTitle;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passengersController = TextEditingController();

  //// Flight details
  final TextEditingController depFlightController = TextEditingController();
  final TextEditingController arrivalFlightController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double companyPrice = double.tryParse(widget.company['price'].toString()) ?? 0.0;

    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          _showNoInternetDialog(context);
        }

        return  Scaffold(
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
                        _buildSectionTitle('Terminal Selections'),
                        _selectTerminal(),
                        // // _buildSectionTitle('Explore Additional Services'),
                        // _buildAdditionalServices(context, companyPrice),
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
      },
    );
  }
  void _showNoInternetDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoInternetDialog(
          checkConnectivity: () {
            Provider.of<ConnectivityProvider>(context, listen: false).checkConnectivity();
          },
        ),
      );
    });
  }

  Widget _selectTerminal() {
    return Row(
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
            backgroundImage: NetworkImage('https://m.media-amazon.com/images/I/51h590Ep9hL.png'), // Replace with actual image asset
          ),
          title:  Text('${user?['title']}, ${user?['first_name']} ${user?['last_name']}'),
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
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Add Flight Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Departure Flight',
                          hintText: 'Enter Flight Number',
                          obscureText: false,
                          icon: Icons.person,
                          controller: depFlightController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Departure Flight Number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'Arrival Flight',
                          hintText: 'Enter Flight Number',
                          obscureText: false,
                          icon: Icons.person,
                          controller: arrivalFlightController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Arrival Flight Number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'Passengers',
                          hintText: 'Enter Total Passengers',
                          obscureText: false,
                          icon: Icons.person,
                          controller: passengersController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Total Passengers';
                            }
                            return null;
                          },
                        ),
                        // if (_promoState == "expired") promoCodeExpired(),
                        // if (_promoState == "removed") promoCodeRemoved(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.maybePop(context);
                              }
                            },
                            child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
            ////print('Selected Vehicle: $_selectedVehicle');
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
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return FutureBuilder<List<Vehicle>>(
              future: fetchVehiclesByCustomer('${user?['id']}').then(
                    (data) => data.map((vehicle) => Vehicle.fromMap(vehicle)).toList(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text("Failed to load vehicles")),
                  );
                }
                List<Vehicle> vehicles = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Select a Vehicle',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Show vehicle list if available
                      if (vehicles.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = vehicles[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.10), width: 1.0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    child: ListTile(
                                      leading: Image.asset('assets/images/car.png', width: 40),
                                      title: Text(vehicle.make),
                                      subtitle: Text(
                                        'Model: ${vehicle.model}, Color: ${vehicle.color}, Reg: ${vehicle.registration}',
                                      ),
                                      onTap: () {
                                        _onVehicleSelected(vehicle);
                                        // Navigator.pop(context); // Close modal after selection
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        const SizedBox(
                          child: Center(child: Text("No vehicles available")),
                        ),
                      // "Manage Vehicles" button is always visible
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomButton(
                          text: 'Manage Vehicles',
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.vehicleManagement);
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }


  Widget _buildContinueButton(BuildContext context, Vehicle? vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (vehicle != null && selectedDropoffTerminalId != null && selectedPickupTerminalId != null) {
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
                  'ArrivalFlightNo': arrivalFlightController.text,
                  'DepartureFlightNo': depFlightController.text,
                  'registration': vehicle!.registration!,
                  'make': vehicle.make!,
                  'color': vehicle.color!,
                  'model': vehicle.model!,
                  'deprTerminal': selectedDropoffTerminalId.toString(),
                  'returnTerminal': selectedPickupTerminalId.toString(),
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text, 
                  'phoneNumber': phoneNumberController.text,
                  'title': selectedTitle.toString(),
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    vehicle == null
                        ? 'Please select a vehicle to continue.'
                        : 'Please select both drop-off and pick-up terminals to continue.',
                  ),
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
    late FocusNode focusNode;
    bool isFocused = false;

    @override
    void initState() {
      super.initState();
      focusNode = FocusNode();
      focusNode.addListener(() {
        setState(() {
          isFocused = focusNode.hasFocus;
        });
      });
    }

    @override
    void dispose() {
      focusNode.dispose();
      super.dispose();
    }

    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Add User Information',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Title',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person,
                                  color: isFocused ? Colors.red : Colors.grey,
                                ),
                              ),
                              hint: Text("Select title"),
                              style: Theme.of(context).textTheme.labelLarge,
                              value: selectedTitle,
                              items: ['Mr', 'Ms', 'Mrs', 'Dr']
                                  .map((title) => DropdownMenuItem(
                                value: title,
                                child: Text(title),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedTitle = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a title';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'First Name',
                                hintText: 'First Name',
                                obscureText: false,
                                icon: Icons.person,
                                controller: firstNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                label: 'Last Name',
                                hintText: 'Last Name',
                                obscureText: false,
                                icon: Icons.person,
                                controller: lastNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Last name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            IntlMobileField(
                              decoration: InputDecoration(
                                // labelText: 'Mobile Number',
                                hintText: 'Phone Number',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.redAccent)
                                ),
                              ),
                              controller: phoneNumberController,
                              initialCountryCode: 'GB',
                              // disableLengthCounter: true,
                              languageCode: "en",
                              validator: (value) {
                                if (value == null ) {
                                  return 'Please enter your phone number';
                                }
                                if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value as String)) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            )
                          ],
                        ),
                        // if (_promoState == "expired") promoCodeExpired(),
                        // if (_promoState == "removed") promoCodeRemoved(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.maybePop(context);
                              }
                            },
                            child: const Text("Add", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

}