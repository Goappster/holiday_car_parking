import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


void main () {
  runApp(BookingConfirmation());
}

class BookingConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Booking Confirmation'),
        // ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icon(
              //   Icons.check_circle,
              //   color: Colors.green,
              //   size: 100,
              // ),
              Lottie.asset('assets/payment_confirm.json', height: 250,  fit: BoxFit.fill),
              // SizedBox(height: 16),
              Text(
                'Booking Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '£55.48',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.green),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Image.asset('assets/images/purple.png'), // Ensure you have this asset
                title: Text('Purpule Express Charge & Go'),
                subtitle: Text('Street 123, Airparks'),
              ),
              Divider(),
              ListTile(
                title: Text('Drop-Off'),
                trailing: Text('Thu 21 Nov 2024 at 09:00'),
              ),
              ListTile(
                title: Text('Return'),
                trailing: Text('Fri 20 Dec 2024 at 09:00'),
              ),
              ListTile(
                title: Text('Booking Price'),
                trailing: Text('£ 53.49',

                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.green),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8),
                // color: Colors.grey[200],
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Image.asset('assets/images/barcode.png'),
                    Text('34568543475985', style: TextStyle(fontSize: 18)),// Ensure you have this asset
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}