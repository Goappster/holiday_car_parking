import 'package:flutter/material.dart';

class TimeDisplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The provided timestamp
    final String currentTime = '2025-01-14T18:15:09+05:00';

    return Scaffold(
      appBar: AppBar(
        title: Text('Current Local Time'),
      ),
      body: Center(
        child: Text(
          'The current local time is: $currentTime',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
