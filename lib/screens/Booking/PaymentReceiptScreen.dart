import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/UiHelper.dart';

class PaymentReceiptScreen extends StatelessWidget {
  // final String amount;
  final String source;

  final Map<String, dynamic> data;

  const PaymentReceiptScreen(
      {super.key, required this.data, required this.source});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isCredit = data['type'] == 'credit';

    // Function to determine color based on status
    Color getStatusColor(String status) {
      switch (status) {
        case "Request Received":
          return Colors.orange; // Request Received
        case "Sent to Accounts Department":
          return Colors.blue; // Sent to Accounts Department
        case "Withdraw Approved":
          return Colors.orange; // Withdraw Approved
        case "Posted to Account":
          return Colors.green; // Posted to Account
        default:
          return Colors.black; // Default color
      }
    }

    // Function to get icon based on status
    IconData getStatusIcon(String status) {
      switch (status) {
        case "Request Received":
          return Icons.hourglass_empty; // Request Received (Pending)
        case "Sent to Accounts Department":
          return Icons.account_balance; // Sent to Accounts Department
        case "Withdraw Approved":
          return Icons.check_circle_outline; // Withdraw Approved
        case "Posted to Account":
          return Icons.account_balance_wallet; // Posted to Account
        default:
          return Icons.help_outline; // Default icon
      }
    }

    String status = data['status'] ?? 'N/A';
    Color statusColor = getStatusColor(status);

    return Scaffold(
      backgroundColor: Color(0xFF105D38),
      body: Stack(
        children: [
          /// **Top Ribbon SVG**
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: isPortrait ? screenHeight * 0.20 : screenHeight * 0.1,
              // Adjust height dynamically based on screen height
              child: SvgPicture.asset(
                "assets/ribbon.svg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              // Padding based on screen width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// **Title**
                  ///
                  Text(
                    "Payment Receipt",
                    style: TextStyle(
                      fontSize: screenWidth * 0.053,
                      // Font size based on screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03), // Adjusted spacing
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
                          height: isPortrait
                              ? screenHeight * 0.75
                              : screenHeight * 0.5,
                          // Adjust height based on screen size
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// **Receipt Content**
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        // Padding based on screen width
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            source == 'withdrawStatus'
                                ? SizedBox(
                              height: 40,
                              width: 40,
                              child: CircleAvatar(
                                backgroundColor: getStatusColor(status),
                                // .withOpacity(0.10),
                                child: Icon(getStatusIcon(status), size: 35,),
                              ),
                            )
                                : SvgPicture.asset(
                              "assets/success_icon.svg",
                              width: screenWidth * 0.27,
                              // Adjust icon size based on screen width
                              height: screenWidth *
                                  0.27, // Adjust icon size based on screen width
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            source == 'withdrawStatus' ? Text(
                              status,
                              style: TextStyle(
                                fontSize: screenWidth * 0.048,
                                // Adjust font size based on screen width
                                fontWeight: FontWeight.bold,
                              ),
                            ) : Text(
                              "Payment Success",
                              style: TextStyle(
                                fontSize: screenWidth * 0.048,
                                // Adjust font size based on screen width
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Adjusted spacing
                            Text(
                              "Your payment for booking has been successfully completed",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Adjusted spacing
                            Text(
                              "Total Payment",
                              style: TextStyle(color: Colors.grey),
                            ),
                            source == 'withdrawStatus'
                                ? Text(
                                '\$${data['amount'] ?? '0.00'}',
                                style: TextStyle(
                                    color: isCredit
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth *
                                        0.08)
                            )
                                : Text(
                              '${isCredit ? "+" : "-"}${data['amount'] ?? "0"}',
                              style: TextStyle(
                                  color: isCredit
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth *
                                      0.08), // Adjust font size for the amount
                            ),
                            SizedBox(height: screenHeight * 0.04),
                            DottedDashedLine(
                              height: 0,
                              width: double.infinity,
                              axis: Axis.horizontal,
                              dashColor: Theme.of(context).dividerColor,
                              dashSpace: 8,
                            ),
                            // SizedBox(height: screenHeight * 0.06),
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blue.shade50,
                                      // Light background for better visibility
                                      child: Icon(Icons.payment,
                                          color: Colors.blue,
                                          size: 24), // Adjust icon size
                                    ),
                                    SizedBox(width: screenWidth * 0.04),
                                    // Transaction Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //   "Balance ${isCredit ? "Credit" : "Debit" ?? '0'}",
                                          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          // ),
                                          source == 'withdrawStatus'
                                              ? Row(
                                            children: [
                                              Icon(Icons.history, color: Colors.blue, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                "${data['transaction_id']?? "Request Received" }",
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          )
                                              : Row(
                                            children: [
                                              Icon(Icons.payment, color: Colors.blue, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                "Visa **** 1234",
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          source == 'withdrawStatus'
                                              ? Text(data['created_at'])
                                              : Text(
                                            DateFormat(
                                                'EEEE MMMM yyyy hh:mm a')
                                                .format(DateTime.parse(
                                                data['created_at'])),
                                          ),
                                          source == 'withdrawStatus'
                                              ? Text(data['transaction_id'] ?? '',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12))
                                              : Text('Nothing'),
                                        ],
                                      ),
                                    ),
                                    // Transaction Amount & Status
                                    source == 'withdrawStatus'
                                        ? Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                              getStatusIcon(status),
                                              color: statusColor),
                                        ),
                                      ],
                                    )
                                        : Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "Success",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Adjusted spacing
                            CustomButton(
                              onPressed: () => Share.share(
                                  'Check out this amazing app: https://play.google.com/store/apps/details?id=com.holiday.car.parking.uk'),
                              text: "Share",
                              backgroundColor: Colors.green,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Adjusted spacing
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: CustomText(
                                text: 'Back',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                                fontSizeFactor: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: Lottie.asset(
                  'assets/ribbon.json'), // Lottie animation stays at the top
            ),
          ),
        ],
      ),
    );
  }
}
