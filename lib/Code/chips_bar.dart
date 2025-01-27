import 'package:flutter/material.dart';

class SelectableChipsWithImages extends StatefulWidget {
  @override
  _SelectableChipsWithImagesState createState() =>
      _SelectableChipsWithImagesState();
}

class _SelectableChipsWithImagesState extends State<SelectableChipsWithImages> {
  final List<Map<String, dynamic>> chipData = [
    {"label": "Apple Pay", "image": "assets/images/applepay_logo.png"},
    {"label": "PayPal", "image": "assets/images/paypal_logo.png"},
    {"label": "Visa", "image": "assets/images/visa_logo.png"},
  ];

  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selectable Payment Methods")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(chipData.length, (index) {
                final chip = chipData[index];
                final bool isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = isSelected ? -1 : index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.transparent: Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          chip["image"],
                          height: 20,

                        ),
                        const SizedBox(width: 8),
                        Text(
                          chip["label"],
                          style: TextStyle(
                            color: isSelected ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (_selectedIndex != -1) ...[
              // Conditional layout based on the selected payment method
              if (chipData[_selectedIndex]["label"] == "Apple Pay") ...[
                _applePayLayout(),
              ] else if (chipData[_selectedIndex]["label"] == "PayPal") ...[
                _paypalLayout(),
              ] else if (chipData[_selectedIndex]["label"] == "Visa") ...[
                _visaLayout(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _applePayLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Apple Pay Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Enter your Apple Pay details here."),
        // You can add Apple Pay-specific widgets here.
      ],
    );
  }

  Widget _paypalLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PayPal Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Log in to your PayPal account."),
        // You can add PayPal-specific widgets here.
      ],
    );
  }

  Widget _visaLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Visa Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Enter your Visa card details."),
        // You can add Visa-specific widgets here.
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SelectableChipsWithImages(),
  ));
}
