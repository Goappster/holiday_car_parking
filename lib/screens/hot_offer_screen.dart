

import 'package:flutter/material.dart';

class HotOffersSection extends StatelessWidget {
  const HotOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280, // Set a fixed height for each card
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          OfferCard(
            title: 'Purple Parking',
            description: 'Purple Express Charge & Power...',
            rating: 4.7,
            price: '£45.40',
            imageSource: 'assets/images/purple.png',
          ),
          OfferCard(
            title: 'Holiday Parking',
            description: 'Holiday Extras Express & Charge...',
            rating: 4.2,
            price: '£25.40',
            imageSource: 'assets/images/Express.png',
          ),
          OfferCard(
            title: 'Purple Parking',
            description: 'Purple Express Charge & Power...',
            rating: 4.7,
            price: '£45.40',
            imageSource: 'assets/images/purple.png',
          ),
          OfferCard(
            title: 'Purple Parking',
            description: 'Purple Express Charge & Power...',
            rating: 4.7,
            price: '£45.40',
            imageSource: 'assets/images/purple.png',
          ),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final double rating;
  final String price;
  final String imageSource;

  const OfferCard({
    super.key,
    required this.title,
    required this.description,
    required this.rating,
    required this.price,
    required this.imageSource,
  });

  @override
  Widget build(BuildContext context) {
    //print("Building card for $title"); // Debugging output
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 180,
        // height: 100, // Ensure a fixed height for the card
        child: Card(
          // color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Image.asset(
                        imageSource,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                         //print("Image load error: $error"); // Debugging output
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          rating.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.yellow, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        price,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}