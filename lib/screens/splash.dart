import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
    @override
  void initState() {
    super.initState();
    _checkToken();
    _controller = VideoPlayerController.asset('assets/car.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown after the video is initialized
      })
      ..setLooping(true)
      ..play();
  }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      // Navigate to home screen if token exists
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (route) => false, // This condition removes all previous routes
      );
    } else {
      // Navigate to login screen if no token
      // Navigator.pushNamed(
      //   context,
      //   AppRoutes.login,
      // );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/images/Splash.png', // Ensure the image is in assets and added in pubspec.yaml
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Stack(
            children: [
              Positioned.fill(
                child: _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : Container(color: Colors.black),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 150, // Adjust height as needed
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Gradient overlay
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.9)],
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //       ),
          //     ),
          //   ),
          // ),
          // Text and button content
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.red.withOpacity(0.0),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/LogoWhite.png',
                        height: 60,),
                        const SizedBox(height: 10),
                        const Text(
                          'One stop ultimate solution to airport parking.',
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Swipe button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/Signup');
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Colors.redAccent, Colors.red],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          // boxShadow: const [
                          //   BoxShadow(
                          //     color: Colors.black45,
                          //     blurRadius: 10,
                          //     offset: Offset(0, 4),
                          //   ),
                          // ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lets Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
