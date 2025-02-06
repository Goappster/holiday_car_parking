import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: SupportTicketForm());
//   }
// }

class SupportTicketForm extends StatefulWidget {
  @override
  _SupportTicketFormState createState() => _SupportTicketFormState();
}

class _SupportTicketFormState extends State<SupportTicketForm> {
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _loadUserData();

  }


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


  String?  fullName, email, contact, department, priority, subject, message;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show the loading dialog before making the request
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 10),
                Text('Please wait while we process your ticket.'),
              ],
            ),
          );
        },
      );

      // Prepare the request
      final uri = Uri.parse('https://holidayscarparking.uk/api/createSupportTicket');
      final response = await http.post(
        uri,
        body: {
          'referenceNo': _referenceNoController.text,
          'full_name': '${user?['title']} ${user?['first_name']} ${user?['last_name']}',
          'email': '${user?['email']}',
          'contact': '${user?['phone_number']}',
          'department': department,
          'priority': priority,
          'subject': subject,
          'message': message,
          'attachment': _imageFile?.path ?? '', // Handle attachment
        },
      );

      // Close the loading dialog
      Navigator.of(context).pop();

      // Handle the response
      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final ticket_ref = responseBody['ticket_ref'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Success! Your ticket has been submitted.'),
              content: Text(
                '🔑 Ticket ID: $ticket_ref\n\n'
                    'We\'ll get back to you shortly. Thank you for reaching out!',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

      } else {
        // Failure dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Failed to submit ticket.'),
              content: Text('Please try again later.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }


  final TextEditingController _referenceNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('Create Tickets'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10,),
                TextFormField(
                  controller: _referenceNoController,
                  decoration: InputDecoration(labelText: 'Booking Reference No.',

                    suffixIcon: IconButton(
                      icon: Icon(Icons.paste),
                      onPressed: _pasteText,
                    ),),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Support Department'),
                        value: department,  // Set the value (null or any default value if needed)
                        items: <String>['Booking', 'Complaint', 'Amendment', 'Cancellation'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => department = value),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Ticket Priority'),
                        value: priority,  // Set the value (null or any default value if needed)
                        items: <String>['Low', 'Medium', 'High'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => priority = value),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ticket Subject'),
                  onSaved: (value) => subject = value,
                ),
                SizedBox(height: 10,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ticket Message'),
                  maxLines: 3,
                  onSaved: (value) => message = value,
                ),
                SizedBox(height: 10,),
                ListTile(
                  title: Text('Attachment: ${_imageFile?.name ?? "No Image Chosen"}'),
                  trailing: ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Choose Image'),
                  ),
                ),
                SizedBox(height: 20,),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'I Agree To The',
                        style: Theme.of(context).textTheme.titleSmall
                      ),
                      TextSpan(
                        text: 'HolidaysCarParking',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                      TextSpan(
                        text: '\'s Privacy Policy & ',
                          style: Theme.of(context).textTheme.titleSmall
                      ),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          // Handle tap on the Terms & Conditions link
                          print('Tapped Terms & Conditions');
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit Ticket'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _pasteText() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _referenceNoController.text = data.text!;
      });
    }
  }

  @override
  void dispose() {
    _referenceNoController.dispose(); // Clean up the controller when done
    super.dispose();
  }
}

