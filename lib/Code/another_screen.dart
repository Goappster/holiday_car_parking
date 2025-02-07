import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: CupertinoDatePickerScreen(),
    );
  }
}

class CupertinoDatePickerScreen extends StatefulWidget {
  const CupertinoDatePickerScreen({super.key});

  @override
  _CupertinoDatePickerScreenState createState() =>
      _CupertinoDatePickerScreenState();
}

class _CupertinoDatePickerScreenState
    extends State<CupertinoDatePickerScreen> {
  DateTime? _pickupDate;
  DateTime? _dropOffDate;

  void _showCupertinoDatePicker(BuildContext context, bool isPickup) {
    DateTime now = DateTime.now();
    DateTime initialDate = DateTime(now.year, now.month, now.day);
    DateTime minimumDate = isPickup ? initialDate : (_pickupDate ?? initialDate);

    DateTime selectedDate = isPickup
        ? (_pickupDate ?? initialDate)
        : (_dropOffDate ?? minimumDate.add(Duration(days: 1)));

    // Ensure initialDateTime is never before minimumDate
    if (selectedDate.isBefore(minimumDate)) {
      selectedDate = minimumDate;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: Text("Cancel", style: TextStyle(color: Colors.red)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        child: Text("Done", style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          setState(() {
                            if (isPickup) {
                              _pickupDate = selectedDate;
                            } else {
                              _dropOffDate = selectedDate;
                            }
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    minimumDate: minimumDate,
                    maximumDate: DateTime(2100),
                    onDateTimeChanged: (DateTime newDate) {
                      setModalState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pickup & Drop-off Date Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pickup Date Button
            CupertinoButton.filled(
              onPressed: () => _showCupertinoDatePicker(context, true),
              child: Text(
                _pickupDate != null
                    ? DateFormat('EEE, dd MMM yyyy').format(_pickupDate!)
                    : 'Pickup Date',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            // Drop-off Date Button
            CupertinoButton.filled(
              onPressed: () => _showCupertinoDatePicker(context, false),
              child: Text(
                _dropOffDate != null
                    ? DateFormat('EEE, dd MMM yyyy').format(_dropOffDate!)
                    : 'Drop-off Date',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
