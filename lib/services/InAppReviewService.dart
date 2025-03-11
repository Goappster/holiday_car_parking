import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';

import '../Code/noti_test.dart';
enum Availability { loading, available, unavailable }
class InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  Availability _availability = Availability.loading;

  // Singleton pattern for InAppReviewService to ensure a single instance
  static final InAppReviewService _instance = InAppReviewService._internal();

  factory InAppReviewService() {
    return _instance;
  }

  InAppReviewService._internal();

  Availability get availability => _availability;

  Future<void> init() async {
    await _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      _availability = isAvailable ? Availability.available : Availability.unavailable;
    } catch (_) {
      _availability = Availability.unavailable;
    }
  }

  Future<void> requestReview() async {
    if (_availability == Availability.available) {
      await _inAppReview.requestReview();
    } else {
      _openStoreListing();
    }
  }

  Future<void> _openStoreListing() async {
    final packageName = "com.holiday.car.parking.uk";
    final url = "https://play.google.com/store/apps/details?id=$packageName";
    await _inAppReview.openStoreListing(appStoreId: null);
  }
}

class FeedbackDialog extends StatelessWidget {
  final VoidCallback onNegativePressed;
  final VoidCallback onPositivePressed;
  const FeedbackDialog({super.key, required this.onNegativePressed, required this.onPositivePressed});
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        "Enjoying this App?",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        "Hi there! We’d love to know if you’re having a great experience.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed:onNegativePressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "😕",
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(height: 5),
              Text(
                "Not Really",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        CupertinoDialogAction(
          onPressed: onPositivePressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🤗",
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(height: 5),
              Text(
                "Yes!",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
