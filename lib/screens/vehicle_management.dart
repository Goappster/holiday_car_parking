import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holidayscar/utils/UiHelper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/connectivity_provider.dart';
import '../widgets/text.dart';
class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  _VehicleManagementScreenState createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {


  final List<String> vehicleSuggestions = [
    'Mercedes-Benz', 'BMW', 'Audi', 'Tesla', 'Volvo', 'Toyota', 'Ford', 'Volkswagen', 'Skoda', 'Hyundai', 'Nissan', 'Kia', 'Peugeot',
    'Renault', 'Jaguar', 'Land Rover',
    'Lexus', 'Mazda', 'Mitsubishi', 'Porsche', 'Subaru', 'Suzuki', 'Honda', 'Chevrolet', 'Chrysler', 'Dodge', 'Fiat', 'Jeep', 'Genesis',
    'Alfa Romeo', 'Citroën', 'Bugatti', 'Aston Martin', 'Ferrari', 'Lamborghini', 'Maserati', 'Bentley', 'Rolls-Royce',
  ];

  final List<String> vehicleModelSuggestions = [
    '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020',
    '2021', '2022', '2023', '2024', '2005', '2006', '2007', '2008', '2009', '1995', '1996', '1997', '1998', '1999',
    '2000', '2001', '2002', '2003', '2004', '1985', '1986', '1987',
    '1988', '1989', '1990', '1991', '1992', '1993', '1994',
  ];


  List<dynamic> _vehicles = [];
  bool _isLoading = true;
  Map<String, dynamic>? user;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // First, load user data
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
          //print("Failed to parse user data: $e");
          user = null;
        }
      }
    });

    if (user != null) {
      // Fetch vehicles after user is loaded
      await _fetchVehicles();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicles() async {
    if (user == null || user?['id'] == null) {
      setState(() {
        _isLoading = false;
      });
      //print('Error: User ID is null.');
      return;
    }

    try {
      List<dynamic> vehicles = await fetchVehiclesByCustomer('${user?['id']}');
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      //print('Error fetching vehicles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    // final baseColor = isDarkTheme ? AppTheme.darkSurfaceColor : Colors.grey[300]!;
    // final highlightColor = isDarkTheme ? AppTheme.darkTextSecondaryColor : Colors.grey[100]!;
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          _showNoInternetDialog(context);
        }

        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text('Vehicle Management '),
          ),
          body: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : RefreshIndicator(
            onRefresh: _fetchVehicles,
            child: ListView.builder(
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                return GestureDetector(
                  onTap: () {
                    _onVehicleSelected(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Image.asset('assets/images/car.png', width: 50, height: 50, fit: BoxFit.cover,),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicle['make']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${vehicle['registration']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: const Color(0xFF1D9DD9).withOpacity(0.20)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: SvgPicture.asset(
                                              'assets/color.svg',
                                            ),
                                          )),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Color', style: Theme.of(context).textTheme.labelSmall),
                                          const SizedBox(width: 2),
                                          Text('${vehicle['color']}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Container(
                                        height: 32,
                                        width: 32,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: const Color(0xFF33D91D).withOpacity(0.20)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: SvgPicture.asset(
                                            'assets/model.no.svg',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Model No', style: Theme.of(context).textTheme.labelSmall),
                                          const SizedBox(width: 2),
                                          Text('${vehicle['model']}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                //
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => CupertinoActionSheet(
                                    actions: [
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _updateVehicle(context, '${vehicle['registration']}', '${vehicle['make']}', '${vehicle['model']}', '${vehicle['color']}', '${vehicle['id']}');
                                        },
                                        child: const Text("Update", style: TextStyle(color: Colors.blue),),
                                      ),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteVehicle('${vehicle['id']}');
                                        },
                                        isDestructiveAction: true,
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
            child: const Icon(Icons.add, color: Colors.white),
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


  Future<void> deleteVehicle(String vehId) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CupertinoActivityIndicator());
      },
    );

    final String url = 'https://holidayscarparking.uk/api/deleteVehicle';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vehId': vehId, // Passing vehId as a parameter
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Close the loading dialog
        _fetchVehicles();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Vehicle details has been Deleted.'),
              content: const Text(
                'You have successfully Deleted your vehicle details.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _fetchVehicles(); // Refresh the list after closing the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.of(context).pop(); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text('Failed to delete vehicle. Status code:${response.statusCode}')),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error deleting vehicle: $e')),
      );

    }
  }


  void _updateVehicle(BuildContext context, String regNo, String make, String model, String color, String vehId) {
    final formKey = GlobalKey<FormState>();
    final registrationController = TextEditingController(text: regNo);
    final makeController = TextEditingController(text: make);
    final modelController = TextEditingController(text: model);
    final colorController = TextEditingController(text: color);



    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
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
                          'Update Vehicles Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Vehicle Registration',
                        hintText: 'ABC123',
                        obscureText: false,
                        icon: Icons.person,
                        controller: registrationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Vehicle Registration Number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Make',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return vehicleSuggestions.where(
                                    (model) => model.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                              );
                            },
                            onSelected: (String selection) {
                              makeController.text = selection;
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              return TextFormField(
                                controller: controller, // Use the provided controller
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: const InputDecoration(
                                  // labelText: 'Vehicle Model',
                                  hintText: 'Tesla',
                                  prefixIcon: Icon(Icons.directions_car),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Vehicle Model';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vehicle Model',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Autocomplete<String>(
                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }
                                    return vehicleModelSuggestions.where(
                                          (model) => model.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                                    );
                                  },
                                  onSelected: (String selection) {
                                    modelController.text = selection;
                                  },
                                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                    return TextFormField(
                                      controller: controller, // Use the provided controller
                                      focusNode: focusNode,
                                      onEditingComplete: onEditingComplete,
                                      decoration: const InputDecoration(
                                        // labelText: 'Vehicle Model',
                                        hintText: '2019',
                                        prefixIcon: Icon(Icons.directions_car),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your Vehicle Model';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10), // Space between the fields
                          Expanded(
                            child: CustomTextField(
                              label: 'Vehicle Color',
                              hintText: 'Black',
                              obscureText: false,
                              icon: Icons.person,
                              controller: colorController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Vehicle Color';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please enter your Vehicles, Registrations, Model, and color details.',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
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
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              await _updateVehicleApi(registrationController.text, makeController.text, modelController.text, colorController.text, vehId);
                            }
                          },
                          child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onVehicleSelected(int index) {
    final selectedVehicle = _vehicles[index];
    // Perform actions with the selected vehicle
  }

  void _showVehicle(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController registrationController = TextEditingController();
    final TextEditingController makeController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    final TextEditingController colorController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
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
                          'Add Your Vehicles',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Vehicle Registration',
                        hintText: 'ABC123',
                        obscureText: false,
                        icon: Icons.person,
                        controller: registrationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Vehicle Registration Number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Make',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return vehicleSuggestions.where(
                                    (model) => model.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                              );
                            },
                            onSelected: (String selection) {
                              makeController.text = selection;
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              return TextFormField(
                                controller: controller, // Use the provided controller
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: const InputDecoration(
                                  // labelText: 'Vehicle Model',
                                  hintText: 'Japan Motors',
                                  prefixIcon: Icon(Icons.directions_car),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Vehicle Model';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                 'Vehicle Model',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Autocomplete<String>(
                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }
                                    return vehicleModelSuggestions.where(
                                          (model) => model.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                                    );
                                  },
                                  onSelected: (String selection) {
                                    modelController.text = selection;
                                  },
                                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                    return TextFormField(
                                      controller: controller, // Use the provided controller
                                      focusNode: focusNode,
                                      onEditingComplete: onEditingComplete,
                                      decoration: const InputDecoration(
                                        // labelText: 'Vehicle Model',
                                        hintText: '2019',
                                        prefixIcon: Icon(Icons.directions_car),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your Vehicle Model';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),

                          ),
                          const SizedBox(width: 10), // Space between the fields
                          Expanded(
                            child: CustomTextField(
                              label: 'Vehicle Color',
                              hintText: 'Black',
                              obscureText: false,
                              icon: Icons.person,
                              controller: colorController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Vehicle Color';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please enter your Vehicles, Registrations, Model, and color details.',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(text: 'Save',
                        onPressed: () async {
                        // print(registrationController.text,);
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            await _addVehicle(
                              registrationController.text,
                              makeController.text,
                              modelController.text,
                              colorController.text,
                              '${user?['id']}',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addVehicle(String registration, String make, String model, String color, String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CupertinoActivityIndicator());
      },
    );

    try {
      final response = await http.post(
        Uri.parse('https://holidayscarparking.uk/api/addVehicle'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'registration': registration,
          'make': make,
          'model': model,
          'color': color,
          'user_id': userId,
        }),
      );

      Navigator.of(context).pop(); // Close the loading dialog

      if (response.statusCode == 200) {
        _fetchVehicles();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Vehicle has been added'),
              content: const Text(
                'You have successfully added a vehicle to your list.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Refresh the list after closing the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
      if (kDebugMode) {
        print(response.body);
      }
        _showErrorDialog('Failed to add vehicle. Please try again.');
      }
    } catch (e) {
     //debug//print('$e');
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog('An error occurred. Please check your connection.');
    }
  }

  Future<void> _updateVehicleApi(String registration, String make, String model, String color, String vehId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CupertinoActivityIndicator());
      },
    );

    try {
      final response = await http.post(
        Uri.parse('https://holidayscarparking.uk/api/updateVehicle'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'vehId': vehId,
          'make': make,
          'model': model,
          'color': color,
          'registration': registration,
        }),
      );

      Navigator.of(context).pop(); // Close the loading dialog

      if (response.statusCode == 200) {
        _fetchVehicles();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Vehicle details has been Updated'),
              content: const Text(
                'You have successfully Updated your vehicle details.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _fetchVehicles(); // Refresh the list after closing the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
       //debug//print(response.body);
        _showErrorDialog('Failed to add vehicle. Please try again.');
      }
    } catch (e) {
     //debug//print('$e');
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog('An error occurred. Please check your connection.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('❌ Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
   //debug//print('Error fetching vehicles: $e');
    return [];
  }
}
