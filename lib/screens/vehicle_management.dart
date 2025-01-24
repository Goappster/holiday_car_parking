import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../widgets/text.dart';

class VehicleManagementScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onVehicleSelected;

  VehicleManagementScreen({required this.vehicles, required this.onVehicleSelected});
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle'),
      ),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return VehicleListItem(vehicle: vehicle, onVehicleSelected: onVehicleSelected);
        },
      ),
      floatingActionButton: FloatingActionButton(
       shape: CircleBorder(),
        onPressed: () {
          _showVehicle(context);
        },
        child: Icon(Icons.add, color: Colors.white,),
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
                    controller: emailController,
                  ),
                  CustomTextField(
                    label: 'Vehicle Make',
                    hintText: 'Japan Motors',
                    obscureText: false,
                    icon: Icons.person,
                    controller: emailController,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Vehicle Color',
                          hintText: 'Black',
                          obscureText: false,
                          icon: Icons.person,
                          controller: emailController,
                        ),
                      ),
                      const SizedBox(width: 10), // Space between the fields
                      Expanded(
                        child: CustomTextField(
                          label: 'Vehicle Model',
                          hintText: '2019',
                          obscureText: false,
                          icon: Icons.person,
                          controller: emailController,
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




class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final Function(Vehicle) onVehicleSelected;

  VehicleListItem({required this.vehicle, required this.onVehicleSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Card(
        child: ListTile(
          leading: Image.asset(vehicle.imageUrl),
          title: Text(vehicle.make),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reg: ${vehicle.registration}'),
              Text('Color: ${vehicle.color}'),
              Text('Model: ${vehicle.model}'),
            ],
          ),
          trailing: Icon(Icons.edit),
          onTap: () => onVehicleSelected(vehicle),
        ),
      ),
    );
  }
}

class AddVehicleForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Vehicle Registration'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Vehicle Make'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Vehicle Color'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Vehicle Model'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle add vehicle action
                },
                child: Text('Add Vehicle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
