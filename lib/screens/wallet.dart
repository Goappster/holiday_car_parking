import 'package:flutter/material.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/ImageSlider.dart';
import 'PaymentReceiptScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WalletDashboard(),
    );
  }
}

class WalletDashboard extends StatelessWidget {

  final List<String> images = [
    'https://i.pinimg.com/474x/c2/b0/1a/c2b01ac41b052535bc3871e85f86753c.jpg',
    'https://i.pinimg.com/736x/de/26/05/de26051a2c73292f11cd91b8ede87a66.jpg',
    'https://i.pinimg.com/736x/1a/26/fd/1a26fdceeec831daae488589936e2116.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('My Wallet', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Updated Balance', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₤1,93,450',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.refresh, color: Theme.of(context).primaryColor),
              ],
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount:4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildQuickAction(context,LucideIcons.circle, 'Scan & Pay'),
                _buildQuickAction(context,Icons.account_balance, 'Bank Transfer'),
                _buildQuickAction(context,Icons.swap_horiz, 'Transfer'),
                _buildQuickAction(context,LucideIcons.ticket, 'Voucher Code'),
              ],
            ),
            Text('Promo & Offers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),
            // SizedBox(height: 20),
            ImageSlider(imageUrls: images),
             // Container(
             //    height: 100,
             //    width: double.infinity,
             //    padding: EdgeInsets.all(10),
             //    decoration: BoxDecoration(
             //      color: Theme.of(context).primaryColor.withOpacity(0.20),
             //      borderRadius: BorderRadius.circular(8),
             //    ),
             //    child: Text('Invite friends and get ₤1,000 reward',
             //        style: TextStyle(color: Theme.of(context).primaryColor)),
             //  ),

            SizedBox(height: 30),
            // Text('SEND MONEY',
            //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // SizedBox(height: 10),
            // Row(
            //   children: [
            //     _buildSendMoneyAvatar(Icons.add, 'New', isAdd: true),
            //     _buildSendMoneyAvatar(null, 'Miss Schu',
            //         imageUrl: 'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611765.jpg?t=st=1740055441~exp=1740059041~hmac=fdf268f79ec8d527e5838f1e64d3521ef8651e5821e10426615384e5fbd85692&w=740'),
            //     _buildSendMoneyAvatar(null, 'Cori Harve',
            //         imageUrl: 'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611722.jpg?t=st=1740055486~exp=1740059086~hmac=062738756dccd34120cf6fadb6605fe94dfdc91768d45060f098b8c11a7876e6&w=740'),
            //     _buildSendMoneyAvatar(null, 'Milly Oqu',
            //         imageUrl: 'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611725.jpg?t=st=1740055521~exp=1740059121~hmac=db6aa55a3935eea7ef4d7d8f4fb723a706c31e3d4cb0902f64d00c4ab928698e&w=740'),
            //     _buildSendMoneyAvatar(null, 'Risa Midy',
            //         imageUrl: 'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611698.jpg?t=st=1740055597~exp=1740059197~hmac=5b367b433bda071feec67de68828158d151496975eb6145fa01ff0ea0b3b4865&w=740'),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECENT TRANSACTIONS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('View All',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
            ListTile(
              leading: Icon(LucideIcons.ticket, color: Colors.red,),
              title: Text('Airport booking'),
              subtitle: Text('01 Jan - Subscription payment'),
              trailing: Text('-1,200', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentReceiptScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.creditCard, color: Colors.green,),
              title: Text('Funds Added'),
              subtitle: Text('01 Jan - Visa Card Payment'),
              trailing: Text(
                '+1,200',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentReceiptScreen()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context,IconData icon, String label, ) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.10),
          child: Icon(icon,  color: Theme.of(context).primaryColor),
        ),
        SizedBox(height: 5),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSendMoneyAvatar(IconData? icon, String name, {String? imageUrl, bool isAdd = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isAdd ? AppTheme.primaryColor.withOpacity(0.10) : Colors.transparent,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: isAdd ? Icon(icon, color: AppTheme.primaryColor) : null,
          ),
          SizedBox(height: 5),
          Text(name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
