// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:holidayscar/theme/app_theme.dart';
// import 'package:holidayscar/utils/UiHelper.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/connectivity_provider.dart';
//
// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//
//       ],
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Material App',
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ConnectivityProvider>(
//       builder: (context, provider, child) {
//         if (!provider.isConnected) {
//           _showNoInternetDialog(context);
//         }
//
//         return Scaffold(
//           appBar: AppBar(),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 16),
//                     Text("Account Settings",
//                         style: Theme.of(context).textTheme.headlineMedium),
//                     Text(
//                       "Update your settings like notifications, payments, profile edit etc.",
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     const SizedBox(height: 24),
//                     ProfileMenuCard(
//                       icon: Icons.person,
//                       title: "Profile Information",
//                       subTitle: "Change your account information",
//                       press: () {
//                         Navigator.pushNamed(context, AppRoutes.editProfile);
//                       },
//                     ),
//                     ProfileMenuCard(
//                       icon: Icons.privacy_tip,
//                       title: "Privacy Policy",
//                       subTitle: "Read our privacy policy",
//                       press: _privacy,
//                     ),
//                     ProfileMenuCard(
//                       // svgSrc: disclaimerIconSvg,
//                       title: "terms & conditions",
//                       subTitle: "terms-and-conditions",
//                       press: _termsApp,
//                       icon: Icons.help,
//                     ),
//                     ProfileMenuCard(
//                       icon: Icons.share,
//                       title: "Share App",
//                       subTitle: "Share this app with your friends",
//                       press: _shareApp,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//   void _showNoInternetDialog(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => NoInternetDialog(
//           checkConnectivity: () {
//             Provider.of<ConnectivityProvider>(context, listen: false).checkConnectivity();
//           },
//         ),
//       );
//     });
//   }
// }
