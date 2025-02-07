import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
import '../theme/app_theme.dart';
import 'booking_confirmation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;
  Map<String, dynamic>? user;
  Future<void>? _userDataFuture;
  bool _isShimmerVisible = true;
  Timer? _shimmerTimer;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
    _shimmerTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isShimmerVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _shimmerTimer?.cancel();
    super.dispose();
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
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user?['first_name']} ${user?['last_name']}!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
            ),
            Text(
              DateFormat('dd MMM, yyyy').format(DateTime.now()), // Formats current date
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only( right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // Rounded corners
              border: Border.all(
                color: Colors.grey, // Stroke color
                width: 1, // Stroke width
              ),
            ),
            child: Center(
              child:  IconButton(
                icon: Icon(MingCute.notification_line, size: 20,),
                onPressed: () {
                  // CupertinoAlertDialog(
                  //   title: const Text('Confirm Logout'),
                  //   content: const Text('Are you sure you want to logout?'),
                  //   actions: [
                  //     CupertinoDialogAction(
                  //       onPressed: () => Navigator.of(context).pop(false),
                  //       child: const Text('Cancel'),
                  //     ),
                  //     CupertinoDialogAction(
                  //       onPressed: () => Navigator.of(context).pop(true),
                  //       child: const Text('Logout'),
                  //     ),
                  //   ],
                  // );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('Release Notes.'),
                        content: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🌟 Key Features'),
                            Text('🔐 User Authentication'),
                            Text('📅 Booking Management'),
                            Text('💳 Payment Processing'),
                            Text('🎁 Promotional Offers'),
                            SizedBox(height: 8), // Spacing

                            Text('⏰ Time Display'),
                            Text('🚀 Improvements'),
                            Text('• Faster data retrieval for a smoother experience.'),
                            Text('• Enhanced UI/UX for a user-friendly interface.'),
                            SizedBox(height: 8), // Spacing

                            Text('⚠️ Known Issues'),
                            Text('• Minor UI glitches on certain devices. We\'re working on it!'),
                            SizedBox(height: 8), // Spacing

                            Text('🔮 Coming Soon'),
                            Text('• More payment options.'),
                            Text('• Improved user profile features.'),
                          ],
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

                },
              ),

            ),
          ),
        ],
      ),

      body: _isShimmerVisible
          ? Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 10),
                const DateTimePickerSection(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hot Offers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
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
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const DateTimePickerSection(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hot Offers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
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
  }
}

class DateTimePickerSection extends StatefulWidget {
  const DateTimePickerSection({super.key});
  @override
  _DateTimePickerSectionState createState() => _DateTimePickerSectionState();
}

class _DateTimePickerSectionState extends State<DateTimePickerSection> {

  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

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
          color: Theme.of(context).cardColor,
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
      return 'Drop-off Date - Pick-Up Date';
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkTheme ? AppTheme.darkSurfaceColor : Colors.grey[300]!;
    final highlightColor = isDarkTheme ? AppTheme.darkTextSecondaryColor : Colors.grey[100]!;

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
                      return Shimmer.fromColors(
                          baseColor: baseColor, highlightColor: highlightColor,
                          child: Container(
                            width: double.infinity,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ));
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No airports available');
                    } else {
                      final airports = snapshot.data!;
                      return InkWell(
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
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
                                  const Icon(MingCute.airplane_line, color: Colors.red),
                                  const SizedBox(width: 5,),
                                  Flexible(
                                    child:  Text(
                                      _selectedAirportName ?? "Select Airport",
                                      // style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => CupertinoActionSheet(
                              title: Text("Select Airport"),
                              actions: [
                                Container(
                                  height: 200,
                                  child: CupertinoPicker(
                                    itemExtent: 60.0,
                                    onSelectedItemChanged: (int index) {
                                      setState(() {
                                        _selectedAirportId = airports[index]['id'];
                                        _selectedAirportName = airports[index]['name'];
                                      });
                                    },
                                    children: airports.map((airport) {
                                      return Center(
                                        child: Text(airport['name']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                child: Text("Done"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _showCupertinoDatePicker(context, false),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
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
                            const Icon(MingCute.calendar_2_line, color: Colors.red),
                            const SizedBox(width: 5,),
                            Flexible(
                              child: Text(
                                _dropOffDate != null
                                    ? DateFormat('EEE, dd MMM yyyy').format(_dropOffDate!)
                                    : 'Drop-off Date',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _showCupertinoDatePicker(context, true),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
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
                            const Icon(MingCute.calendar_2_line, color: Colors.red),
                            const SizedBox(width: 5,),
                            Flexible(
                              child: Text(
                                _pickupDate != null
                                    ? DateFormat('EEE, dd MMM yyyy').format(_pickupDate!)
                                    : 'Pickup Date',
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
                            borderRadius: BorderRadius.circular(12),
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
                                  const SizedBox(width: 5,),
                                  Flexible(
                                    child: Text(
                                      style: Theme.of(context).textTheme.labelMedium,
                                      _selectedStartTime != null
                                        ? _formatTimeOfDay(_selectedStartTime)
                                        : 'Drop-Off Time',
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
                            borderRadius: BorderRadius.circular(12),
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
                                  const SizedBox(width: 5,),
                                  Flexible(
                                    child: Text(
                                      style: Theme.of(context).textTheme.labelMedium,
                                      _selectedEndTime != null
                                        ? _formatTimeOfDay(_selectedEndTime)
                                        : 'Pick-up Time',
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
                          _pickupDate == null ||
                          _dropOffDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select all inputs.')),
                        );
                        return;
                      }
                      // Combine and format date and time
                      final startDate = _formatDate(_dropOffDate);
                      final endDate = _formatDate(_pickupDate);
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
