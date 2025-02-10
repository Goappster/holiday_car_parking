import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(settings);
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        await Permission.notification.request();
      }
    }
  }

  Future<String> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isGranted) return "Granted";
      if (status.isDenied) return "Denied";
      if (status.isPermanentlyDenied) return "Permanently Denied";
    }
    return "Unknown";
  }

  Future<void> showNotification(String refId, ) async {
    var permissionStatus = await Permission.notification.status;
    if (!permissionStatus.isGranted) {
      await requestPermissions();
    }

    if (await Permission.notification.isGranted) {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'custom_channel_id',
        'Custom Notifications',
        channelDescription: 'Channel for custom notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        0,  // Notification ID (can be unique)
        '🎉 Whoo-hoo!! #$refId',
        '🚗 Your VIP parking is locked in—zero stress, all perks! Pull up & own your spot. 🔥✅',
        notificationDetails,
      );
    }
  }

}
