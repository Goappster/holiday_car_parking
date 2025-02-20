
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final bool enlargeCenter;

  const ImageSlider({
    Key? key,
    required this.imageUrls,
    this.height = 150.0,
    this.autoPlay = true,
    this.enlargeCenter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        autoPlay: autoPlay,
        enlargeCenterPage: enlargeCenter,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
      items: imageUrls.map((imageUrl) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(imageUrl, fit: BoxFit.cover, width: 1000),
        );
      }).toList(),
    );
  }
}
