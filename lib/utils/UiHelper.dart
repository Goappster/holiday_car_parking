import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/connectivity_provider.dart';
import '../theme/app_theme.dart';

class UiHelper {
  // Screen Size Helpers
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Adaptive Size (no flutter_screenutil package used)
  static Widget verticalSpace(BuildContext context, double percentage) {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(height: height * (percentage / 100));
  }

  // Adaptive height based on screen size
  static double adaptiveHeight(BuildContext context, double percentage) {
    double height = MediaQuery.of(context).size.height;
    return height * (percentage / 100);
  }

  // Adaptive width based on screen size
  static double adaptiveWidth(BuildContext context, double percentage) {
    double width = MediaQuery.of(context).size.width;
    return width * (percentage / 100);
  }

  static double adaptiveFont(BuildContext context, double size) {
    return size * (screenWidth(context) / 375); // Assuming base size of font for width
  }

  // Media Query Helpers
  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 600;
  static bool isLargeScreen(BuildContext context) => screenWidth(context) >= 1080;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1080;

  // Padding Helpers
  static EdgeInsets paddingAll(BuildContext context, double value) =>
      EdgeInsets.all(adaptiveWidth(context, value));

  static EdgeInsets paddingSymmetric(BuildContext context, {double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: adaptiveWidth(context, horizontal),
        vertical: adaptiveHeight(context, vertical),
      );

  static EdgeInsets paddingOnly(BuildContext context, {double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      EdgeInsets.only(
        left: adaptiveWidth(context, left),
        top: adaptiveHeight(context, top),
        right: adaptiveWidth(context, right),
        bottom: adaptiveHeight(context, bottom),
      );

  // Margin Helpers
  static EdgeInsets marginAll(BuildContext context, double value) =>
      EdgeInsets.all(adaptiveWidth(context, value));

  static EdgeInsets marginSymmetric(BuildContext context, {double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: adaptiveWidth(context, horizontal),
        vertical: adaptiveHeight(context, vertical),
      );

  static EdgeInsets marginOnly(BuildContext context, {double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      EdgeInsets.only(
        left: adaptiveWidth(context, left),
        top: adaptiveHeight(context, top),
        right: adaptiveWidth(context, right),
        bottom: adaptiveHeight(context, bottom),
      );

  // SizedBox Helpers
  // static SizedBox verticalSpace(BuildContext context, double height) => SizedBox(height: adaptiveHeight(context, height));
  // static SizedBox horizontalSpace(BuildContext context, double width) => SizedBox(width: adaptiveWidth(context, width));
}




class AdaptiveLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;
  final double padding;
  final BorderRadiusGeometry borderRadius;

  const AdaptiveLoadingIndicator({
    Key? key,
    this.width = 100,
    this.height = 80,
    this.padding = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UiHelper.adaptiveWidth(context, width),
      height: UiHelper.adaptiveHeight(context, height),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(UiHelper.adaptiveWidth(context, padding)),
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}



// Reusable Text




class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSizeFactor;

  const CustomText({
    Key? key,
    required this.text,
    this.style,
    this.fontSizeFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Dynamically calculate font size based on screen width & height
    double baseFontSize = (screenWidth + screenHeight) * 0.022; // Dynamic scaling

    // Apply fontSizeFactor if provided, otherwise use textScaleFactor
    double finalFontSize = baseFontSize * (fontSizeFactor ?? textScaleFactor);

    // Ensure a reasonable minimum font size
    finalFontSize = finalFontSize.clamp(12.0, 28.0);

    TextStyle textStyle = (style ?? Theme.of(context).textTheme.bodyLarge!).copyWith(
      fontWeight: FontWeight.bold,
      fontSize: finalFontSize,
    );

    return Text(
      text,
      style: textStyle,
    );
  }
}



// Reusable Sized Box
class AdaptiveSizedBox extends StatelessWidget {
  final double heightFactor;
  final double widthFactor;

  const AdaptiveSizedBox({
    this.heightFactor = 0.02, // Default to 2% of screen height
    this.widthFactor = 0.0,   // Default to 0, since SizedBox(width) is optional
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SizedBox(
      height: mediaQuery.size.height * heightFactor,
      width: mediaQuery.size.width * widthFactor,
    );
  }
}


// Rubbles filed Button

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor; // Optional background color

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor, // Allow custom background color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth > 600 ? 400 : screenWidth * 0.9; // Adaptive width for larger screens
    double verticalPadding = screenWidth > 600 ? 16 : screenWidth * 0.04; // Adjust padding for large screens

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor, // Use custom or primary color
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



class NoInternetDialog extends StatelessWidget {
  final VoidCallback checkConnectivity;

  const NoInternetDialog({Key? key, required this.checkConnectivity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        // Close the dialog when the internet is restored
        if (provider.isConnected) {
          Future.delayed(Duration(milliseconds: 300), () {
            Navigator.of(context, rootNavigator: true).pop();
          });
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie Animation
                Lottie.asset(
                  'assets/no_internet.json', // Replace with your Lottie file
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 15),

                // Title
                Text(
                  "Oops! No Internet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  "Please check your connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Retry Button
                    ElevatedButton(
                      onPressed: checkConnectivity,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                        elevation: 5,
                      ),
                      child: Text(
                        "Retry",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



