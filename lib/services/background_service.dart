import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'Notifactions.dart';

class BackgroundService {
  static const String notificationChannelId = 'my_foreground';
  static const int notificationId = 888;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await _setupNotifications();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
        notificationChannelId: notificationChannelId,
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> _setupNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'MY FOREGROUND SERVICE',
      description: 'Used for background tasks',
      importance: Importance.min,
      playSound: false,
      enableVibration: false,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  Timer.periodic(Duration(seconds: 30), (timer) {
    // print("Service running: \$${DateTime.now()}");
    WithdrawService().fetchWithdrawStatus();
  });
}

class WithdrawService {
  final String apiUrl = "https://holidayscarparking.uk/api/wallet/withdrawRequestStatus";
  final int userId = 890; // Replace dynamically
  final NotificationService _notificationService = NotificationService();

  Future<void> fetchWithdrawStatus() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"userId": userId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true &&
            data["withdraw_request"]["data"] != null) {
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
              // showNotification("Withdrawal Status Update", "Your withdrawal request (ID: $id) is now: $newStatus");

              _notificationService.showNotification(
                  '🎉 Payment Update!',
                  'Withdrawal Status Update Your withdrawal request (ID: $id) is now: $newStatus'
                      'Date & Time: ${DateFormat('EEE, dd MMM yyyy • HH:mm')
                      .format(DateTime.now())}\n'
                      'Thanks for choosing HCP Wallet! 🚀'
              );
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching withdraw status: $e");
      }
    }
  }
}




// final service = FlutterBackgroundService();
//
// void startService() {
//   service.startService();
//   setState(() {});
// }
//
// void stopService() {
//   service.invoke("stop");
//   setState(() {});
// }
//
