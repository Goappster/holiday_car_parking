import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  // final Map<String, dynamic> company;
  const BookingDetailsScreen({super.key, });

  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final startDate = arguments['Name'];
    final endDate = arguments['Email'];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/purple.png', // Add your image asset here
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                    startDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Street 123, Airparks'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 26,),
              const DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Colors.white70, ),
              const SizedBox(height: 24,),
              buildDetailRow('Drop-Off', 'Thu 21 Nov 2024 at 09:00'),
              buildDetailRow('Return', 'Fri 20 Dec 2024 at 09:00'),
              buildDetailRow('No of Days', '09'),
              const SizedBox(height: 20,),
              const DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Colors.white70, ),
              const SizedBox(height: 20,),
              buildDetailRow('Booking Price', '53.49'),
              buildDetailRow('Booking Fee', '1.99'),
              const SizedBox(height: 20,),
              const DottedDashedLine(height: 0, width: double.infinity, axis: Axis.horizontal, dashColor: Colors.white70, ),
              const SizedBox(height: 20,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '£55.48',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 22,),
              Card(
                // margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/purple.png', // Update with your logo path
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(startDate,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Street 123, Airparks',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.edit, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(Icons.local_shipping, 'Drop-Off',
                              '21/11/24 at 9:00'),
                          _buildInfoColumn(Icons.calendar_today, 'Return',
                              '20/12/24 at 9:00'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                              Icons.attach_money, 'Booking Price', '53.49'),
                          _buildInfoColumn(
                              Icons.percent, 'Booking Fee', '1.99'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }


  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}