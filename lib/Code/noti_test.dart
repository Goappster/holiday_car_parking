// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../services/Notifactions.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService().init();
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Local Notifications',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HomeScreen(),
//     );
//   }
// }
//
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
// class _HomeScreenState extends State<HomeScreen> {
//
//
//   final NotificationService _notificationService = NotificationService();
//   String _permissionStatus = "Unknown";
//
//   @override
//   void initState() {
//     super.initState();
//     _updatePermissionStatus();
//   }
//
//   void _updatePermissionStatus() async {
//     String status = await _notificationService.checkPermissionStatus();
//     setState(() {
//       _permissionStatus = status;
//     });
//
//     if (status == "Permanently Denied") {
//       _showSettingsDialog();
//     }
//     if (status == "Denied") {
//       _showSettingsDialog();
//     }
//   }
//
//   void _showSettingsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Notification Permission Required"),
//         content: Text(
//           "Notifications are permanently denied. Please enable them from settings.",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await openAppSettings();
//             },
//             child: Text("Open Settings"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Local Notifications")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => _notificationService.showNotification('Hello',),
//               child: Text("Send Custom Notification"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _updatePermissionStatus,
//               child: Text("Check Permission Status"),
//             ),
//             SizedBox(height: 10),
//             Text("Permission Status: $_permissionStatus"),
//           ],
//         ),
//       ),
//     );
//   }
// }
