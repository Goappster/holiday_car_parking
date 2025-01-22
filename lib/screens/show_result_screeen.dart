import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:holidayscar/screens/booking.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';

class ShowResultsScreen extends StatefulWidget {
  const ShowResultsScreen({super.key});
  @override
  State<ShowResultsScreen> createState() => _ShowResultsScreenState();


}

class _ShowResultsScreenState extends State<ShowResultsScreen> {
  String? _selectedOption = 'Low to High';
  final List<String> _filterOptions = [ 'Low to High', 'High to Low'];
  late Future<Map<String, dynamic>> _quotes; // Updated to Future<Map<String, dynamic>>
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();

  }

  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final startDate = arguments['startDate'] ?? 'defaultStartDate';
    final endDate = arguments['endDate'] ?? 'defaultEndDate';
    final startTime = arguments['startTime'] ?? 'defaultStartTime';
    final endTime = arguments['endTime'] ?? 'defaultEndTime';
    final airportId = arguments['AirportId'] ?? 'defaultAirportId';
    final airportName = arguments['AirportName'] ?? 'defaultAirportName';

    _quotes = _apiService.fetchQuotes(
      airportId: airportId,
      dropDate: startDate,
      dropTime: startTime,
      pickDate: endDate,
      pickTime: endTime,
      promo: 'HCP-APP-OXT78U',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Results'),
        elevation: 4,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAirportCard(context,startDate, endDate, startTime, endTime, airportName),
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
                        if (_selectedOption == 'Low to High') {
                          _quotes = _apiService.fetchQuotes(
                            airportId: airportId,
                            dropDate: startDate,
                            dropTime: startTime,
                            pickDate: endDate,
                            pickTime: endTime,
                            promo: 'HCP-APP-OXT78U',
                          ).then((data) {
                            final companies = data['companies'] as List<dynamic>;
                            companies.sort((a, b) => double.parse(a['price'].toString()).compareTo(double.parse(b['price'].toString())));
                            return data;
                          });
                        } else if (_selectedOption == 'High to Low') {
                          _quotes = _apiService.fetchQuotes(
                            airportId: airportId,
                            dropDate: startDate,
                            dropTime: startTime,
                            pickDate: endDate,
                            pickTime: endTime,
                            promo: 'HCP-APP-OXT78U',
                          ).then((data) {
                            final companies = data['companies'] as List<dynamic>;
                            companies.sort((a, b) => double.parse(b['price'].toString()).compareTo(double.parse(a['price'].toString())));
                            return data;
                          });
                        }
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
              _buildOffersList(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirportCard(BuildContext context, String startDate, String endDate, String startTime, String endTime, String ariportName, ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('B-18', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Text(ariportName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/Booking');
                  },
                  icon: Icon(MingCute.edit_4_fill, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  Text('$startDate \n$startTime'),
                  const Icon(Icons.calendar_today, color: Colors.green),
                  Text('$endDate \n$endTime'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(BuildContext context) {
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
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        } else {
          final offers = snapshot.data!;
          final companies = offers['companies'] as List<dynamic>?;

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
                      builder: (context) =>  BookingScreen(company: company,),
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

  Widget _buildOfferCard(dynamic offer, BuildContext context) {
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
                  offer['companyID'].toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      offer['price'].toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '£ ${offer['price']}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
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
