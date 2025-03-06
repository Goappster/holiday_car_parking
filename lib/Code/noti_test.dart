import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

void main() => runApp( MyApp()); // Use MyApp as the root widget

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const InAppReviewExampleApp(),
      // Other properties like theme, localization, etc. can be added as well.
    );
  }
}

enum Availability { loading, available, unavailable }

class InAppReviewExampleApp extends StatefulWidget {
  const InAppReviewExampleApp({super.key});

  @override
  InAppReviewExampleAppState createState() => InAppReviewExampleAppState();
}

class InAppReviewExampleAppState extends State<InAppReviewExampleApp> {
  final InAppReview _inAppReview = InAppReview.instance;
  Availability _availability = Availability.loading;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      setState(() {
        _availability = isAvailable ? Availability.available : Availability.unavailable;
      });
    } catch (_) {
      setState(() => _availability = Availability.unavailable);
    }
  }

  Future<void> _requestReview() async {
    if (_availability == Availability.available) {
      await _inAppReview.requestReview();
    } else {
      _openStoreListing();
    }
  }

  Future<void> _openStoreListing() async {
    final packageName = "com.holiday.car.parking.uk"; // Replace with your app’s package name
    final url = "https://play.google.com/store/apps/details?id=$packageName";
    await _inAppReview.openStoreListing(appStoreId: null);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Play In-App Review')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('In App Review status: ${_availability.name}'),
            ElevatedButton(
              onPressed: _requestReview,
              child: const Text('Request Review'),
            ),
            ElevatedButton(
              onPressed: () => _showFeedbackDialog(context),
              child: const Text('Open Play Store Listing'),
            ),
          ],
        ),
      ),
    );
  }

}













//
void _showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
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
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
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
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}