import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holidayscar/screens/booking.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';
import 'package:intl/intl.dart';
class ShowResultsScreen extends StatefulWidget {
  const ShowResultsScreen({super.key});
  @override
  State<ShowResultsScreen> createState() => _ShowResultsScreenState();
}

class _ShowResultsScreenState extends State<ShowResultsScreen> {
  String? _selectedOption = 'Low to High';
  final List<String> _filterOptions = ['Low to High', 'High to Low'];
  Future<Map<String, dynamic>>? _quotes; // Nullable Future
  late ApiService _apiService;

  // Initialize variables with temporary default values
  String? airportId;
  String airportName = 'defaultAirportName';
  String startDate = 'defaultStartDate';
  String endDate = 'defaultEndDate';
  String startTime = 'defaultStartTime';
  String endTime = 'defaultEndTime';

  @override
  void initState() {
    super.initState();

    // Initialize the API service
    _apiService = ApiService();

    // Retrieve route arguments in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      setState(() {
        airportId = arguments['AirportId'];
        airportName = arguments['AirportName'];
        startDate = arguments['startDate'];
        endDate = arguments['endDate'];
        startTime = arguments['startTime'];
        endTime = arguments['endTime'];

        _quotes = _apiService.fetchQuotes(
          airportId: airportId!,
          dropDate: startDate,
          dropTime: startTime,
          pickDate: endDate,
          pickTime: endTime,
          promo: 'HCP-APP-OXT78U',
        ).then((data) {
          final companies = data['companies'] as List<dynamic>;
          if (_selectedOption == 'Low to High') {
            companies.sort((a, b) => double.parse(a['price'].toString()).compareTo(double.parse(b['price'].toString())));
          } else if (_selectedOption == 'High to Low') {
            companies.sort((a, b) => double.parse(b['price'].toString()).compareTo(double.parse(a['price'].toString())));
          }
          return data;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Results'),
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pass the required parameters to the airport card
              _buildAirportCard(context, startDate, endDate, startTime, endTime, airportName, {}),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available For You',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    iconEnabledColor: Theme.of(context).primaryColor,
                    icon: const Icon(MingCute.filter_line),
                    underline: const SizedBox.shrink(),
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                        _quotes?.then((data) {
                          final companies = data['companies'] as List<dynamic>;
                          if (_selectedOption == 'Low to High') {
                            companies.sort((a, b) =>
                                double.parse(a['price'].toString()).compareTo(double.parse(b['price'].toString())));
                          } else if (_selectedOption == 'High to Low') {
                            companies.sort((a, b) =>
                                double.parse(b['price'].toString()).compareTo(double.parse(a['price'].toString())));
                          }
                          return data;
                        });
                      });
                    },
                    items: _filterOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildOffersList(context, startDate, endDate, startTime, endTime),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAirportCard(
      BuildContext context,
      String startDate,
      String endDate,
      String startTime,
      String endTime,
      String airportName,
      Map<String, dynamic> offer,
      ) {
    // Extract reviews from the offer
    final List<Map<String, dynamic>> reviews = (offer['reviews'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Calculate average rating
    double averageRating = reviews.isNotEmpty
        ? reviews
        .map((review) => review['rating'] ?? 0)
        .fold(0.0, (sum, rating) => sum + (rating as double)) / reviews.length
        : 0.0;

    // Round the average rating and cast to int
    int roundedRating = averageRating.isNaN ? 0 : averageRating.round();
    DateTime startDateTime = DateTime.parse(startDate); // Convert String to DateTime
    DateTime endDateTime = DateTime.parse(endDate);
    // DateTime departureTime = DateTime.parse(startTime);
    // DateTime returnTime = DateTime.parse(endTime);


    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Airport Name and Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.airplanemode_active,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      airportName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/Booking');
                    print(endTime);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date and Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color(0xFF1D9DD9)
                              .withOpacity(0.20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgPicture.asset(
                          'assets/map_blue.svg',
                          // semanticsLabel: 'My SVG Image',
                          // height: 10,
                          // width: 10,
                          // fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(startDateTime)),
                        Text(
                          '$startTime',
                          style: TextStyle(color: Colors.grey),  // Change the color here
                        )
                      ],
                    ),

                  ],
                ),
                SizedBox(width: 0),

                Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color(0xFF33D91D)
                              .withOpacity(0.20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgPicture.asset(
                          'assets/map.svg',
                          // semanticsLabel: 'My SVG Image',
                          // height: 10,
                          // width: 10,
                          // fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(endDateTime)),
                        Text(
                          endTime,
                          style: TextStyle(color: Colors.grey),  // Change the color here
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }




  Widget _buildOffersList(BuildContext context, String startDate, String endDate, String startTime, String endTime,) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _quotes, // The Future to wait for (which returns a Map)
      builder: (context, snapshot) {
        final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
        final baseColor = isDarkTheme ? AppTheme.darkSurfaceColor : Colors.grey[300]!;
        final highlightColor = isDarkTheme ? AppTheme.darkTextSecondaryColor : Colors.grey[100]!;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                childAspectRatio: 0.60,
              ),
              itemCount: 10, // Number of shimmer effects you want to display
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                // child: Container(color: Colors.white),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          //print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        } else {
          final offers = snapshot.data!;
          final companies = offers['companies'] as List<dynamic>?;
          final totalDays = snapshot.data?['total_days'].toString();
          if (companies == null || companies.isEmpty) {
            return const Center(child: Text('No companies available.'));
          }
          return GridView.builder(
             shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              childAspectRatio: 0.60,
            ),
            itemCount: companies.length, // Using the length of the companies list
            itemBuilder: (context, index) {
              final company = companies[index]; // Access each offer in the companies list
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  BookingScreen(
                        company: company,
                        totalDays: totalDays.toString(),
                        startDate: startDate,
                        endDate: endDate,
                        startTime: startTime,
                        endTime: endTime,
                        airportId: airportId!,
                      ),
                    ),
                  );
                },
                child: _buildOfferCard(company, context), // Build your offer card
              );
            },
          );
        }
      },
    );
  }
  Widget _buildOfferCard(dynamic offer, BuildContext context,) {
    return Card(
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
                  child: offer['park_api'] == 'DB'
                      ? CachedNetworkImage(
                          imageUrl:
                          'https://airportparkbooking.uk/storage/${offer['logo']}',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // placeholder: (context, url) =>
                          //     const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : offer['park_api'] == 'holiday'
                      ? CachedNetworkImage(
                    imageUrl:
                    offer['logo'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // placeholder: (context, url) =>
                    // const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  )
                      : _errorImageWidget(), // Optional: you can return an error widget if the condition doesn't match
                ),

                const SizedBox(height: 8),
                Text(
                  offer['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  offer['parking_type'],
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      (offer['reviews'] != null &&
                          offer['reviews'] is List &&
                          (offer['reviews'] as List).isNotEmpty &&
                          offer['reviews'][0]['rating'] != null)
                          ? offer['reviews'][0]['rating'].toString()
                          : 'No rating',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (offer['reviews'] != null &&
                        offer['reviews'] is List &&
                        (offer['reviews'] as List).isNotEmpty &&
                        offer['reviews'][0]['rating'] != null) ...[
                      const SizedBox(width: 4),
                      for (int i = 0; i < offer['reviews'][0]['rating']; i++) // Dynamically generate stars
                        const Icon(Icons.star, color: Colors.yellow, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    //print(offer); // To see the complete structure
                    //print(offer['reviews']);
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '£ ${offer['price'].toString().replaceAll(',', '')}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorImageWidget() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey,
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.red),
      ),
    );
  }
}
