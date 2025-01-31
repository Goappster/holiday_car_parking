// import 'package:flutter/material.dart';
//
// Widget _applePayLayout() {
//   return  const SizedBox(
//     width: double.infinity,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Coming soon!!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         // You can add Apple Pay-specific widgets here.
//       ],
//     ),
//   );
// }
//
// Widget _paypalLayout() {
//   return const SizedBox(
//     width: double.infinity,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Coming soon!!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         // You can add PayPal-specific widgets here.
//       ],
//     ),
//   );
// }
//
// Widget _visaLayout() {
//   return  SizedBox(
//     width: double.infinity,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Enter Card Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),   InkWell(
//               onTap: () async {
//                 Navigator.maybePop(context);
//                 // await saveCardAndMakePayment(context, '$totalPrice');
//                 // postBookingData('100', 'pi_3QnIGhIpEtljCntg0HwhBvBc');
//
//                 Navigator.pushNamed(context, '/PaymentConfirm',
//                   arguments: {
//                     'company': company,
//                     'startDate': startDate,
//                     'endDate': endDate,
//                     'startTime': startTime,
//                     'endTime': endTime,
//                     'totalPrice': bookingPrice,
//                     'endTimsavedReferenceNoe': '112221211121654'
//                   },
//                 );
//               },
//               child: Text(
//                 '*Autofill Link',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         // CardField(
//         //   onCardChanged: (cardDetails) {
//         //     setState(() {
//         //       // _cardDetails = cardDetails! as CardDetails;
//         //     });
//         //   },
//         // ),
//         const SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // _buildButton(context, 'Cancel', Theme.of(context).colorScheme.surface, Colors.red),
//             // _buildButton(context, 'Confirm', Colors.red, Colors.white),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.maybePop(context);
//                 // postBookingData('100');
//                 // saveIncompleteBooking( company, airportId, startDate, endDate, startTime, endTime,totalDays,totalPrice,priceTotal);
//               },
//               style: ElevatedButton.styleFrom(
//                 // minimumSize: const Size( w48),   minimumSize: const Size( w48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//               child: const Text(
//                 'Pay Now',
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
//
//
// void _showPaymentOptions(BuildContext context,) {
//   final List<Map<String, dynamic>> chipData = [
//     {"label": "Visa", "image": "assets/images/visa_logo.png"},
//     {"label": "PayPal", "image": "assets/images/paypal_logo.png"},
//     {"label": "Apple Pay", "image": "assets/images/applepay_logo.png"},
//   ];
//
//   showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     builder: (BuildContext context) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: List.generate(chipData.length, (index) {
//                 final chip = chipData[index];
//                 return ValueListenableBuilder<int>(
//                   valueListenable: _selectedIndexNotifier,
//                   builder: (context, selectedIndex, _) {
//                     final bool isSelected = selectedIndex == index;
//                     return GestureDetector(
//                       onTap: () {
//                         _selectedIndexNotifier.value = index;
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: isSelected ? Theme.of(context).primaryColor: Colors.transparent,
//                           borderRadius: BorderRadius.circular(50),
//                           border: Border.all(
//                             color: isSelected ? Colors.red : Colors.grey.shade300,
//                             width: 1.5,
//                           ),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               chip["image"],
//                               height: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               chip["label"],
//                               // style: TextStyle(
//                               //   color: isSelected ? Colors.white : Colors.black,
//                               // ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//             const SizedBox(height: 20),
//             ValueListenableBuilder<int>(
//               valueListenable: _selectedIndexNotifier,
//               builder: (context, selectedIndex, _) {
//                 if (selectedIndex != -1) {
//                   if (chipData[selectedIndex]["label"] == "Apple Pay") {
//                     return _applePayLayout();
//                   } else if (chipData[selectedIndex]["label"] == "PayPal") {
//                     return _paypalLayout();
//                   } else if (chipData[selectedIndex]["label"] == "Visa") {
//                     return _visaLayout();
//                   }
//                 }
//                 return Container(); // Empty container until a selection is made
//               },
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
//
// final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);
// @override
// void dispose() {
//   _selectedIndexNotifier.dispose();
//   super.dispose();
// }
