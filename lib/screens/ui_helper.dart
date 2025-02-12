import 'package:flutter/material.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:intl/intl.dart';

class UiHelper {
  static Widget buildContainer({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    // Get screen width & height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Check screen size categories
    bool isLargeScreen = screenWidth > 600; // Large screen (e.g., tablets)
    bool isSmallScreen = screenWidth <= 350; // Small screen (e.g., small phones)

    // Dynamic sizes based on screen type
    double fontSize = isLargeScreen ? 20 : (isSmallScreen ? 16 : 13);
    double containerHeight = isLargeScreen ? 70 : (isSmallScreen ? 50 : 56);
    double paddingSize = isLargeScreen ? 20 : (isSmallScreen ? 12 : 16);
    double borderRadiusSize = isLargeScreen ? 16 : (isSmallScreen ? 8 : 12);
    double iconSize = isLargeScreen ? 28 : (isSmallScreen ? 18 : 24);

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: isLargeScreen ? 6 : 4),
          Container(
            width: double.infinity,
            height: containerHeight,
            padding: EdgeInsets.symmetric(horizontal: paddingSize),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadiusSize),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppTheme.primaryColor, size: iconSize),
                  SizedBox(width: isLargeScreen ? 16 : 12),
                ],
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'Select $label',
                    style: TextStyle(
                      fontSize: fontSize, // Slightly larger text for better visibility
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  static String formatDate(DateTime? date) {
    return date != null ? DateFormat('EEE, dd MMM yyyy').format(date) : 'Select Date';
  }

  static String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatTime(TimeOfDay? time) {
    return time == null ? '' : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
