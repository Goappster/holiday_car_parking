import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CompanyLogoWidget extends StatelessWidget {
  final Map<String, dynamic> company;

  const CompanyLogoWidget({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(3)),
      child: company['park_api'] == 'DB'
          ? CachedNetworkImage(
              imageUrl: 'https://airportparkbooking.uk/storage/${company['logo']}',
              height: 40,
              width: 60,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : company['park_api'] == 'holiday'
              ? CachedNetworkImage(
                  imageUrl: company['logo'],
                  height: 40,
                  width: 60,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : null,
    );
  }
}
