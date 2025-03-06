
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:holidayscar/screens/hot_offer_screen.dart';
import 'package:holidayscar/screens/search_screen.dart';
import 'package:holidayscar/utils/ui_helper_date.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import '../services/InAppReviewService.dart';
import '../services/get_airports.dart';
import '../theme/app_theme.dart';
import '../utils/UiHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppReviewService _inAppReviewService = InAppReviewService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String? token;
  Map<String, dynamic>? user;
  bool _isShimmerVisible = true;
  Timer? _shimmerTimer;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    initializeLocalNotifications();
    requestPermissions();
    _initializeInAppReview();
    _loadUserData();

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

  // Initialize Firebase and Notification Settings
  void initializeFirebase() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        String? imageUrl = message.data['image']; // Get image URL from FCM payload
        await showNotification(message.notification?.title, message.notification?.body, imageUrl);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  // Initialize local notifications
  Future<void> initializeLocalNotifications() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request permissions for notifications
  void requestPermissions() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
  }

  // Show notification with image
  Future<void> showNotification(String? title, String? body, String? imageUrl) async {
    var androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',  // Default Android icon
    );
    var platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformDetails, payload: 'item x');
  }

  Future<void> _initializeInAppReview() async {
    await _inAppReviewService.init();
    setState(() {});
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('dd MMM, yyyy').format(DateTime.now()),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(MingCute.notification_line, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FeedbackDialog(
                    onNegativePressed: () => Navigator.pop(context),
                    onPositivePressed: () async {
                      if (mounted) {
                        _inAppReviewService.requestReview();
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isShimmerVisible
          ? Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: buildBody(),
      )
          : buildBody(),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
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
    );
  }
}

class DateTimePickerSection extends StatefulWidget {
  const DateTimePickerSection({super.key});

  @override
  _DateTimePickerSectionState createState() => _DateTimePickerSectionState();
}

class _DateTimePickerSectionState extends State<DateTimePickerSection> {
  TimeOfDay? _selectedStartTime, _selectedEndTime;
  DateTime? _pickupDate, _dropOffDate;
  late Future<List<Map<String, dynamic>>> _airportData;
  int? _selectedAirportId;
  String? _selectedAirportName;

  @override
  void initState() {
    super.initState();
    _airportData = GetAirports.fetchAirports();
  }

  Future<void> _showDatePicker(BuildContext context, bool isPickup) async {
    DateTime now = DateTime.now();
    DateTime initialDropOffDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    DateTime initialPickupDate = _pickupDate ?? _dropOffDate ?? initialDropOffDate;
    DateTime selectedDate = isPickup ? (_pickupDate ?? initialPickupDate) : (_dropOffDate ?? initialDropOffDate);
    DateTime minimumDate = isPickup ? (_dropOffDate ?? initialDropOffDate) : initialDropOffDate;
    minimumDate = minimumDate.isAfter(selectedDate) ? selectedDate : minimumDate;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          height: 300,
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(
            children: [
              _buildCupertinoToolbar(context, isPickup, selectedDate),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: minimumDate,
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    setStateModal(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (isPickup) {
                      _pickupDate = selectedDate;
                      if (_dropOffDate == null || _dropOffDate!.isAfter(_pickupDate!)) {
                        _dropOffDate = _pickupDate;
                      }
                    } else {
                      _dropOffDate = selectedDate;
                      if (_pickupDate == null || _pickupDate!.isAfter(_dropOffDate!)) {
                        _pickupDate = _dropOffDate;
                      }
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoToolbar(BuildContext context, bool isPickup, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoButton(
            child: const Text("Done", style: TextStyle(color: Colors.blue)),
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
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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

  void _onFindParkingPressed() {
    if (_selectedStartTime == null || _selectedEndTime == null || _pickupDate == null || _dropOffDate == null || _selectedAirportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all inputs.')));
      return;
    }

    Navigator.pushNamed(context, '/ShowResult', arguments: {
      'startDate': UiHelperDate.formatDate(_dropOffDate),
      'endDate': UiHelperDate.formatDate(_pickupDate),
      'startTime': UiHelperDate.formatTime(_selectedStartTime),
      'endTime': UiHelperDate.formatTime(_selectedEndTime),
      'AirportId': _selectedAirportId.toString(),
      'AirportName': _selectedAirportName,
    });
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Airport', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _airportData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No airports available');
                    } else {
                      final airports = snapshot.data!;
                      return GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoActionSheet(
                                title: const Text("Select Airport"),
                                actions: airports.map((airport) {
                                  return CupertinoActionSheetAction(
                                    child: Text(airport['name']),
                                    onPressed: () {
                                      setState(() {
                                        _selectedAirportId = airport['id'];
                                        _selectedAirportName = airport['name'];
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }).toList(),
                                cancelButton: CupertinoActionSheetAction(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              );
                            },
                          );
                        },
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
                            child: Row(
                              children: [
                                const Icon(MingCute.airplane_line, color: Colors.red),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    _selectedAirportName ?? "Select Airport",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                UiHelperDate.buildContainer(
                  label: "Drop-off Date",
                  value: UiHelperDate.formatDate(_dropOffDate),
                  onTap: () => _showDatePicker(context, false),
                  icon: Icons.event,
                  context: context,
                ),
                const SizedBox(height: 16),
                UiHelperDate.buildContainer(
                  label: "Pickup Date",
                  value: UiHelperDate.formatDate(_pickupDate),
                  onTap: () => _showDatePicker(context, true),
                  icon: Icons.calendar_today,
                  context: context,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: UiHelperDate.buildContainer(
                        label: "Drop-Off Time",
                        value: UiHelperDate.formatTimeOfDay(_selectedStartTime),
                        onTap: () => _selectTime(context, true),
                        icon: Icons.access_time,
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: UiHelperDate.buildContainer(
                        label: "Pick-up Time",
                        value: UiHelperDate.formatTimeOfDay(_selectedEndTime),
                        onTap: () => _selectTime(context, false),
                        icon: Icons.timer,
                        context: context,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(text: 'Find Parking', onPressed: _onFindParkingPressed),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
