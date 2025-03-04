import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BackgroundNotificationService {
  static const String apiUrl = "https://holidayscarparking.uk/api/wallet/withdrawRequestStatus";
  static int userId = 890; // Replace with actual logged-in user ID

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  static Future<void> fetchWithdrawStatus() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"userId": userId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true && data["withdraw_request"]["data"] != null) {
          List<dynamic> transactions = data["withdraw_request"]["data"];

          SharedPreferences prefs = await SharedPreferences.getInstance();

          for (var tx in transactions) {
            int id = tx['id'];
            String newStatus = tx['status'] ?? 'N/A';

            // Retrieve the last stored status
            String? lastStatus = prefs.getString('withdraw_status_$id');

            if (lastStatus == null || lastStatus != newStatus) {
              // Save the new status
              prefs.setString('withdraw_status_$id', newStatus);

              // Send notification only if status changed
              showNotification("Withdrawal Status Update", "Your withdrawal request (ID: $id) is now: $newStatus");
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching withdraw status: $e");
    }
  }


  static void showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "withdraw_updates",
      "Withdraw Status",
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}

Future<bool> onStart(ServiceInstance service) async {
  Timer.periodic(Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        BackgroundNotificationService.fetchWithdrawStatus();
      }
    }
  });

  return true;
}
void initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // ✅ Correct function reference
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: "withdraw_status_channel",
      initialNotificationTitle: "Monitoring Withdraw Status",
      initialNotificationContent: "Fetching withdrawal status...",
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(
      onBackground: onStart, // ✅ Pass function reference, don't call it
      onForeground: onStart,
    ),
  );

  service.startService();

  // Initialize Local Notifications
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await BackgroundNotificationService.flutterLocalNotificationsPlugin.initialize(initSettings);
}
