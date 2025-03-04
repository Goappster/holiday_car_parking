import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// A service to manage local notifications in a Flutter application.
/// Supports both Android and iOS platforms.
class NotificationService {
  // Flutter Local Notifications Plugin instance
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  /// Sets up notification settings for both Android and iOS.
  Future<void> init() async {
    // Android notification settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS notification settings with permission request
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // General notification initialization settings
    final InitializationSettings settings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    // Initialize the notifications plugin
    await _notificationsPlugin.initialize(settings);

    // Request necessary permissions
    await requestPermissions();
  }

  /// Requests notification permissions from the user.
  /// Handles both Android and iOS permission requests.
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Checks and returns the current notification permission status.
  Future<String> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isGranted) return "Granted";
      if (status.isDenied) return "Denied";
      if (status.isPermanentlyDenied) return "Permanently Denied";
    }
    return "Unknown";
  }

  /// Displays a local notification with a given [title] and [body].
  /// Automatically checks and requests notification permissions if needed.
  Future<void> showNotification(String title, String body) async {
    // Check permission status on Android before displaying notification
    if (Platform.isAndroid) {
      var permissionStatus = await Permission.notification.status;
      if (!permissionStatus.isGranted) {
        await requestPermissions();
      }
    }

    // Ensure permission is granted before showing the notification
    if ((Platform.isAndroid && await Permission.notification.isGranted) || Platform.isIOS) {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'custom_channel_id', // Channel ID
        'Custom Notifications', // Channel Name
        channelDescription: 'Channel for custom notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation( // Enables expandable notification
          body, // Expanded text when the notification is expanded
          contentTitle: title,
          summaryText: 'More details',
        ),
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      // Generate a unique notification ID to prevent overwriting
      int notificationId = Random().nextInt(100000);

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
    }
  }
}
