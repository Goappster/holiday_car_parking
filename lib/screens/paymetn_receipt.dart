
import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import '../theme/app_theme.dart';
import '../utils/UiHelper.dart';

class PaymentReceipt extends StatefulWidget {
  const PaymentReceipt({super.key});

  @override
  State<PaymentReceipt> createState() => _PaymentReceiptState();
}

class _PaymentReceiptState extends State<PaymentReceipt> {
  @override
  Widget build(BuildContext context) {
    // Get device screen width and height using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final Map<String, dynamic>? booking =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Payment Receipt")),
        body: const Center(child: Text("No booking data available")),
      );
    }

    // Parsing DateTime safely
    DateTime departureDate = DateTime.tryParse(booking['departure_date'] ?? '') ?? DateTime.now();
    DateTime returnDate = DateTime.tryParse(booking['return_date'] ?? '') ?? DateTime.now();
    // Request permission for saving images (needed for Android 9 and below)
    Future<bool> requestPermission() async {
      PermissionStatus storagePermission;
      if (Platform.isAndroid) {
        if (await Permission.storage.isGranted) {
          return true; // Permission already granted
        }
        if (Platform.isAndroid && (await Permission.storage.request()).isGranted) {
          return true;
        }
        if (Platform.isAndroid && await Permission.manageExternalStorage.request().isGranted) {
          return true;
        }
      }

      return false;
    }


    final ScreenshotController screenshotController = ScreenshotController();
    bool isDownloading = false;

    Future<void> captureAndSaveReceipt() async {
      setState(() => isDownloading = true);

      try {
        // Check if permission is granted for storage
        if (!await requestPermission()) {
          throw Exception("Storage permission denied.");
        }

        // Capture screenshot
        Uint8List? imageBytes = await screenshotController.capture();
        if (imageBytes == null) {
          throw Exception("Failed to capture receipt.");
        }

        // Save image to gallery
        final result = await ImageGallerySaverPlus.saveImage(
          imageBytes,
          name: "receipt_${DateTime.now().millisecondsSinceEpoch}",
          quality: 100,
        );

        if (result != null && (result['filePath'] != null || result['fileUri'] != null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Receipt saved successfully!")),
          );
        } else {
          throw Exception("Failed to save receipt.");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() => isDownloading = false);
      }
    }



    return Scaffold(
      backgroundColor: Color(0xFF105D38),
      body: Stack(
        children: [
          /// **Top Ribbon SVG**
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: isPortrait ? screenHeight * 0.20 : screenHeight * 0.1, // Adjust height dynamically based on screen height
              child:
              SvgPicture.asset(
                "assets/ribbon.svg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Screenshot(
            controller: screenshotController,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04), // Padding based on screen width
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// **Title**
                      ///
                      Text(
                        "Payment Receipt",
                        style: TextStyle(
                          fontSize: screenWidth * 0.053, // Font size based on screen width
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01), // Adjusted spacing
                      /// **Receipt Container with SVG Background**
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          /// **SVG Background**
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).cardColor, // Using theme color
                              BlendMode.srcIn, // Apply color filter to SVG
                            ),
                            child: SvgPicture.asset(
                              "assets/receipt_background.svg",
                              width: double.infinity,
                              height: isPortrait ? screenHeight * 0.80 : screenHeight * 0.5, // Adjust height based on screen size
                              fit: BoxFit.fill,
                            ),
                          ),
                          /// **Receipt Content**
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04), // Padding based on screen width
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/success_icon.svg",
                                  width: screenWidth * 0.27, // Adjust icon size based on screen width
                                  height: screenWidth * 0.27, // Adjust icon size based on screen width
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  "Payment Success",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.048, // Adjust font size based on screen width
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01), // Adjusted spacing
                                Text(
                                  "Your payment for booking has been successfully completed",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: screenHeight * 0.02), // Adjusted spacing
                                Text(
                                  "Total Payment",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  "£${booking['total_amount']}",
                                  style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.08), // Adjust font size for the amount
                                ),
                                // Company Info
                                ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      booking['company_logo'] ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error,
                                            size: 50, color: Colors.red);
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    booking['company_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Airport: ${booking['airport_name'] ?? 'N/A'}'),
                                ),
                                // SizedBox(height: screenHeight * 0.04),
                                DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Theme.of(context).dividerColor, dashSpace: 8,),
                                // SizedBox(height: screenHeight * 0.06),
                                // Booking Details Grid
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _infoCard(
                                            "Departure",
                                            DateFormat('dd MMM, hh:mm a')
                                                .format(departureDate),
                                            Icons.local_parking),
                                        _infoCard(
                                            "Return",
                                            DateFormat('dd MMM, hh:mm a')
                                                .format(returnDate),
                                            Icons.flight_land),
                                        _infoCard(
                                            "Days",
                                            "${booking['number_of_days'] ?? 0}",
                                            Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),
                                // Barcode & Reference
                                Column(
                                  children: [
                                    Image.asset(
                                        'assets/images/barcode.png', height: 60),
                                    const SizedBox(height: 2),
                                    Text(
                                      booking['reference_no'] ?? 'N/A',
                                      style: const TextStyle(fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.02), // Adjusted spacing
                                CustomButton(
                                  onPressed: () {
                                    captureAndSaveReceipt();  // Ensure you are calling this method correctly.
                                  },
                                  text: "Sava in device",
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                                SizedBox(height: screenHeight * 0.01), // Adjusted spacing
                                InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: CustomText(text: 'Back', style: TextStyle(color: Colors.grey,), fontSizeFactor: 0.6,),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: Lottie.asset('assets/ribbon.json'), // Lottie animation stays at the top
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Booking Info Cards
  Widget _infoCard(String title, String value, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.10),
            child: Icon(icon, size: 25, color: AppTheme.primaryColor)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:holidayscar/theme/app_theme.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
//
// class PaymentReceipt extends StatelessWidget {
//   const PaymentReceipt({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Retrieve the booking details safely
//     final Map<String, dynamic>? booking =
//     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//
//     if (booking == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Payment Receipt")),
//         body: const Center(child: Text("No booking data available")),
//       );
//     }
//
//     // Parsing DateTime safely
//     DateTime departureDate = DateTime.tryParse(booking['departure_date'] ?? '') ?? DateTime.now();
//     DateTime returnDate = DateTime.tryParse(booking['return_date'] ?? '') ?? DateTime.now();
//     DateTime createdAt = DateTime.tryParse(booking['created_at'] ?? '') ?? DateTime.now();
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: AppBar(
//         title: const Text("Payment Receipt"),
//
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Success Animation
//             Lottie.asset('assets/payment_confirm.json', height: 180, fit: BoxFit.fill),
//             const SizedBox(height: 10),
//
//             // Receipt Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // Total Amount
//                   Text(
//                     '£${booking['total_amount'] ?? '0.00'}',
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Booking Reference
//                   Container(
//                     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryColor.withOpacity(0.10),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       "Ref: ${booking['reference_no'] ?? 'N/A'}",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppTheme.primaryColor,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Company Info
//                   ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         booking['company_logo'] ?? '',
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(Icons.error, size: 50, color: Colors.red);
//                         },
//                       ),
//                     ),
//                     title: Text(
//                       booking['company_name'] ?? 'Unknown',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text('Airport: ${booking['airport_name'] ?? 'N/A'}'),
//                   ),
//
//                   const Divider(thickness: 1, height: 20),
//
//                   // Booking Details Grid
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _infoCard("Departure", DateFormat('dd MMM, hh:mm a').format(departureDate), Icons.flight_takeoff),
//                       _infoCard("Return", DateFormat('dd MMM, hh:mm a').format(returnDate), Icons.flight_land),
//                       _infoCard("Days", "${booking['number_of_days'] ?? 0}", Icons.calendar_today),
//                     ],
//                   ),
//
//                   const Divider(thickness: 1, height: 20),
//
//                   // Barcode & Reference
//                   Column(
//                     children: [
//                       Image.asset('assets/images/barcode.png', height: 60),
//                       const SizedBox(height: 8),
//                       Text(
//                         booking['reference_no'] ?? 'N/A',
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Done Button
//             ElevatedButton.icon(
//               onPressed: () => Navigator.pop(context),
//               icon: const Icon(Icons.check_circle, size: 20),
//               label: const Text("Done"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryColor,
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper Widget for Booking Info Cards
//   Widget _infoCard(String title, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, size: 30, color: AppTheme.primaryColor),
//         const SizedBox(height: 6),
//         Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 4),
//         Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }
