import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     //debugShowCheckedModeBanner: false,
      home: PromoCodeScreen(),
    );
  }
}

class PromoCodeScreen extends StatefulWidget {
  @override
  _PromoCodeScreenState createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _promoController = TextEditingController();
  String _promoState = "none";
  String _errorText = '';

  void applyPromoCode() {
    setState(() {
      if (_promoController.text == "POPFLUX44") {
        _promoState = "applied";
        _errorText = '';
      } else {
        _promoState = "expired";
        _errorText = 'Invalid Promo Code';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_promoState == "applied"
            ? "Promo Code Applied Successfully!"
            : "Promo Code Expired!"),
        backgroundColor: _promoState == "applied" ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void removePromoCode() {
    setState(() {
      _promoState = "removed";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Promo Code Removed"),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void togglePromoCode() {
    setState(() {
      if (_promoState == "applied") {
        _promoState = "removed";
        _promoController.clear();
        _errorText = '';
      } else {
        applyPromoCode();
      }
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Enter Promo Code',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _promoController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Promo code",
                        labelStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.local_offer, color: Colors.blueAccent),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.paste, color: Colors.blueAccent),
                            //   onPressed: () async {
                            //     ClipboardData? data = await Clipboard.getData('text/plain');
                            //     if (data != null) {
                            //       setState(() {
                            //         _promoController.text = data.text ?? '';
                            //       });
                            //     }
                            //   },
                            // ),
                            TextButton(
                              onPressed: () {
                                togglePromoCode();
                                setModalState(() {});
                              },
                              child: Row(
                                children: [
                                  Text(_promoState == "applied" ? "Remove" : "Apply Promo", style: TextStyle(color: Colors.blueAccent)),
                                  // Icon(_promoState == "applied" ? Icons.close : Icons.check, color: Colors.blueAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                        errorText: _errorText.isEmpty ? null : _errorText,
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_promoState == "applied") promoCodeApplied(),
                    // if (_promoState == "expired") promoCodeExpired(),
                    // if (_promoState == "removed") promoCodeRemoved(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          // Add payment logic here
                        },
                        child: const Text("Proceed to Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar to make full screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showBottomSheet(context),
              child: const Text("Enter Promo Code"),
            ),
            const SizedBox(height: 20),
            if (_promoState == "applied") promoCodeApplied(),
            if (_promoState == "expired") promoCodeExpired(),
            if (_promoState == "removed") promoCodeRemoved(),
          ],
        ),
      ),
    );
  }

  // Applied Promo Code UI
  Widget promoCodeApplied() {
    return promoCodeContainer(
      icon: Icons.check_circle,
      iconColor: Colors.green,
      text: "POPFLUX44 -\$20.00 (10% off)",
      message: "Promo Code Applied",
      messageColor: Colors.green,
      onRemove: removePromoCode,
    );
  }

  // Expired Promo Code UI
  Widget promoCodeExpired() {
    return promoCodeContainer(
      icon: Icons.error,
      iconColor: Colors.red,
      text: "POPFLUX44",
      message: "Promo Code Expired",
      messageColor: Colors.red,
      isError: true,
    );
  }

  // Removed Promo Code UI
  Widget promoCodeRemoved() {
    return promoCodeContainer(
      icon: Icons.info,
      iconColor: Colors.blue,
      text: "POPFLUX44",
      message: "Promo Code Removed",
      messageColor: Colors.blue,
    );
  }

  // Generic Promo Code UI Container
  Widget promoCodeContainer({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String message,
    required Color messageColor,
    bool isError = false,
    VoidCallback? onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    message,
                    style: TextStyle(color: messageColor),
                  ),
                ],
              ),
            ],
          ),
          // if (onRemove != null)
          //   TextButton(
          //     onPressed: onRemove,
          //     child: const Text("Remove", style: TextStyle(color: Colors.blue)),
          //   ),
        ],
      ),
    );
  }
}
