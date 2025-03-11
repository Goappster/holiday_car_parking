import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void showCustomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen height
      backgroundColor: Colors.transparent, // Ensures rounded corners
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9, // 90% of screen height
        minChildSize: 0.5, // Can be dragged to 50%
        maxChildSize: 0.95, // Can expand to 95%
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Drag Indicator
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Navigation Bar
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       CupertinoButton(
              //         onPressed: () => Navigator.pop(context),
              //         child: const Text("Cancel"),
              //       ),
              //       const Text(
              //         "New Message",
              //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //       ),
              //       CupertinoButton(
              //         onPressed: () {},
              //         child: const Icon(CupertinoIcons.arrow_up_circle_fill, color: Colors.blue),
              //       ),
              //     ],
              //   ),
              // ),

              // const Divider(height: 1),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoTextField(
                          placeholder: "Email",
                          padding: const EdgeInsets.all(16),
                          keyboardType: TextInputType.emailAddress,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoTextField(
                          placeholder: "Password",
                          padding: const EdgeInsets.all(16),
                          obscureText: true,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            onPressed: () {},
                            child: const Text("Login"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?"),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            CupertinoButton(
                              onPressed: () {},
                              child: const Text("Sign Up"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("iOS Style Bottom Sheet")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showCustomModal(context),
          child: const Text("Show Modal"),
        ),
      ),
    );
  }
}
