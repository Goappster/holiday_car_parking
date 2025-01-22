import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:holidayscar/screens/hot_offer_screen.dart';
import 'package:holidayscar/screens/search_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

import '../services/get_airports.dart';
import '../theme/app_theme.dart'; // Import the intl package for formatting dates

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;
  Map<String, dynamic>? user;
  Future<void>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkTheme ? AppTheme.darkSurfaceColor : Colors.grey[300]!;
    final highlightColor = isDarkTheme ? AppTheme.darkTextSecondaryColor : Colors.grey[100]!;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('Hi, ${user?['first_name']} ${user?['last_name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder(
        future: _userDataFuture, // Simulating a data fetch
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      DateTimePickerSection(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hot Offers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SearchScreen()),
                              );
                            },
                            child: Text('View All', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor)),
                          ),
                        ],
                      ),
                      const HotOffersSection(),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    DateTimePickerSection(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hot Offers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SearchScreen()),
                            );
                          },
                          child: Text('View All', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    ),
                    const HotOffersSection(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class DateTimePickerSection extends StatefulWidget {
  @override
  _DateTimePickerSectionState createState() => _DateTimePickerSectionState();
}

class _DateTimePickerSectionState extends State<DateTimePickerSection> {
  List<DateTime?> _rangeDatePickerWithActionButtonsWithValue = [null, null]; // Initially no date selected
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  Future<void> _showDatePickerDialog(BuildContext context) async {
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      disableModePicker: true,
      rangeBidirectional: true,
    );

    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 370),
      borderRadius: BorderRadius.circular(15),
      value: _rangeDatePickerWithActionButtonsWithValue,
    );

    if (values != null) {
      setState(() {
        _rangeDatePickerWithActionButtonsWithValue = values;
      });
    }
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // Format time
    return format.format(dt);
  }

  String _getValueText(CalendarDatePicker2Type datePickerType, List<DateTime?> values) {
    if (values.length < 2 || (values[0] == null && values[1] == null)) {
      return 'Check in - Check Out';
    }
    values = values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    if (datePickerType == CalendarDatePicker2Type.range) {
      final startDate = values[0]?.toString().replaceAll('00:00:00.000', '') ?? '';
      final endDate = values[1]?.toString().replaceAll('00:00:00.000', '') ?? '';
      return '$startDate to $endDate';
    }
    return 'Invalid';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Helper method to format TimeOfDay as "19:15"
  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  late Future<List<Map<String, dynamic>>> _airportData;

  @override
  void initState() {
    super.initState();
    _airportData = GetAirports.fetchAirports(); // Fetch data only once
  }

  int? _selectedAirportId; // Variable to store selected airport ID
  String? _selectedAirportName; // Variable to store selected airport name

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
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
                      return DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          labelText: 'Select Airport',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        items: airports.map((airport) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: airport,
                            child: Text(airport['name']),
                          );
                        }).toList(),
                        onChanged: (selectedAirport) {
                          setState(() {
                            _selectedAirportId = selectedAirport?['id'];
                            _selectedAirportName = selectedAirport?['name'];
                          });
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _showDatePickerDialog(context),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50), // Rounded corners
                      border: Border.all(
                        color: Colors.grey, // Stroke color
                        width: 1, // Stroke width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Row(
                          children: [
                            const Icon(MingCute.calendar_fill, color: Colors.red),
                            const SizedBox(width: 5,),
                            Flexible(
                              child: Text(
                                _getValueText(
                                  CalendarDatePicker2Type.range,
                                  _rangeDatePickerWithActionButtonsWithValue,
                                ), // Display the date range or default text
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, true),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Row(
                                children: [
                                  const Icon(MingCute.clock_2_line, color: Colors.red),
                                  SizedBox(width: 5,),
                                  Flexible(
                                    child: Text(
                                      _selectedStartTime != null
                                        ? _formatTimeOfDay(_selectedStartTime)
                                        : 'Start Time',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, false),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Row(
                                children: [
                                  const Icon(MingCute.clock_2_line, color: Colors.red),
                                  SizedBox(width: 5,),
                                  Flexible(
                                    child: Text(
                                      _selectedEndTime != null
                                        ? _formatTimeOfDay(_selectedEndTime)
                                        : 'End Time',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedStartTime == null ||
                          _selectedEndTime == null ||
                          _rangeDatePickerWithActionButtonsWithValue[0] == null ||
                          _rangeDatePickerWithActionButtonsWithValue[1] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select all inputs.')),
                        );
                        return;
                      }
                      // Combine and format date and time
                      final startDate = _formatDate(_rangeDatePickerWithActionButtonsWithValue[0]);
                      final endDate = _formatDate(_rangeDatePickerWithActionButtonsWithValue[1]);
                      final startTime = _formatTime(_selectedStartTime);
                      final endTime = _formatTime(_selectedEndTime);

                      Navigator.pushNamed(context, '/ShowResult',
                        arguments: {
                          'startDate': startDate,
                          'endDate': endDate,
                          'startTime': startTime,
                          'endTime': endTime,
                          'AirportId': _selectedAirportId.toString(),
                          'AirportName': _selectedAirportName,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Find Parking'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
