import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../routes.dart';
import '../../utils/UiHelper.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _checkToken();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/car.mp4')
      ..initialize().then((_) => setState(() {}))
      ..setLooping(true)
      ..play();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isSmallScreen = size.width < 600;

    return Scaffold(
     backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
                : Container(color: Colors.black),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: isLandscape ? size.height * 0.3 : size.height * 0.2,
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
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric( horizontal: isLandscape ? size.width * 0.15 : size.width * 0.05, vertical: isLandscape ? size.height * 0.08 : size.height * 0.05,),
                child: Column(
                  mainAxisAlignment: isLandscape ? MainAxisAlignment.center : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/LogoWhite.png',
                          height: isLandscape ? size.height * 0.15 : size.height * 0.08,
                        ),
                        SizedBox(height: size.height * 0.02),
                        CustomText(
                          text: "One stop ultimate solution to airport parking.",
                          style: TextStyle(color: Colors.white),
                          fontSizeFactor: isSmallScreen ? 0.6 : 0.8,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.05),
                    CustomButton(
                      text: 'Let’s Get Started',
                      onPressed: () => Navigator.pushNamed(context, '/Signup'),
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
