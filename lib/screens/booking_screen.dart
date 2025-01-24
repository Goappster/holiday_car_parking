// import 'package:flutter/material.dart';
// import '../services/booking_api.dart';
//
// class BookingScreen extends StatefulWidget {
//   @override
//   _BookingScreenState createState() => _BookingScreenState();
// }
//
// class _BookingScreenState extends State<BookingScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final Map<String, TextEditingController> _controllers = {
//     'title': TextEditingController(),
//     'firstName': TextEditingController(),
//     'lastName': TextEditingController(),
//     'email': TextEditingController(),
//     'contactNo': TextEditingController(),
//     'parkingType': TextEditingController(),
//     'dropDate': TextEditingController(),
//     'dropTime': TextEditingController(),
//     'pickDate': TextEditingController(),
//     'pickTime': TextEditingController(),
//     'totalDays': TextEditingController(),
//     'airportId': TextEditingController(),
//     'productId': TextEditingController(),
//     'productCode': TextEditingController(),
//     'parkApi': TextEditingController(),
//     'bookingAmount': TextEditingController(),
//     'bookingFee': TextEditingController(),
//     'discountAmount': TextEditingController(),
//     'totalAmount': TextEditingController(),
//     'promo': TextEditingController(),
//   };
//
//   @override
//   void dispose() {
//     _controllers.forEach((key, controller) => controller.dispose());
//     super.dispose();
//   }
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       try {
//         await BookingApi().saveIncompleteBooking(
//           title: _controllers['title']!.text,
//           firstName: _controllers['firstName']!.text,
//           lastName: _controllers['lastName']!.text,
//           email: _controllers['email']!.text,
//           contactNo: _controllers['contactNo']!.text,
//           parkingType: _controllers['parkingType']!.text,
//           dropDate: _controllers['dropDate']!.text,
//           dropTime: _controllers['dropTime']!.text,
//           pickDate: _controllers['pickDate']!.text,
//           pickTime: _controllers['pickTime']!.text,
//           totalDays: int.parse(_controllers['totalDays']!.text),
//           airportId: int.parse(_controllers['airportId']!.text),
//           productId: int.parse(_controllers['productId']!.text),
//           productCode: _controllers['productCode']!.text,
//           parkApi: _controllers['parkApi']!.text,
//           bookingAmount: double.parse(_controllers['bookingAmount']!.text),
//           bookingFee: double.parse(_controllers['bookingFee']!.text),
//           discountAmount: double.parse(_controllers['discountAmount']!.text),
//           totalAmount: double.parse(_controllers['totalAmount']!.text),
//           promo: _controllers['promo']!.text,
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Booking saved successfully')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to save booking: $e')),
//         );
//       }
//     }
//   }
//
//   Widget _buildTextFormField(String label, String key, {TextInputType keyboardType = TextInputType.text}) {
//     return TextFormField(
//       controller: _controllers[key],
//       decoration: InputDecoration(labelText: label),
//       keyboardType: keyboardType,
//       validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Booking Form')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildTextFormField('Title', 'title'),
//               _buildTextFormField('First Name', 'firstName'),
//               _buildTextFormField('Last Name', 'lastName'),
//               _buildTextFormField('Email', 'email'),
//               _buildTextFormField('Contact No', 'contactNo'),
//               _buildTextFormField('Parking Type', 'parkingType'),
//               _buildTextFormField('Drop Date', 'dropDate'),
//               _buildTextFormField('Drop Time', 'dropTime'),
//               _buildTextFormField('Pick Date', 'pickDate'),
//               _buildTextFormField('Pick Time', 'pickTime'),
//               _buildTextFormField('Total Days', 'totalDays', keyboardType: TextInputType.number),
//               _buildTextFormField('Airport ID', 'airportId', keyboardType: TextInputType.number),
//               _buildTextFormField('Product ID', 'productId', keyboardType: TextInputType.number),
//               _buildTextFormField('Product Code', 'productCode'),
//               _buildTextFormField('Park API', 'parkApi'),
//               _buildTextFormField('Booking Amount', 'bookingAmount', keyboardType: TextInputType.number),
//               _buildTextFormField('Booking Fee', 'bookingFee', keyboardType: TextInputType.number),
//               _buildTextFormField('Discount Amount', 'discountAmount', keyboardType: TextInputType.number),
//               _buildTextFormField('Total Amount', 'totalAmount', keyboardType: TextInputType.number),
//               _buildTextFormField('Promo', 'promo'),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
