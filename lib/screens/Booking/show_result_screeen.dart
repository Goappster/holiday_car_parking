import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holidayscar/screens/Booking/booking.dart';
import 'package:holidayscar/utils/ui_helper_date.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/api_service.dart';
import '../../services/get_airports.dart';
import '../../utils/UiHelper.dart';
import 'company_details.dart';

class ShowResultsScreen extends StatefulWidget {
  const ShowResultsScreen({super.key});
  @override
  State<ShowResultsScreen> createState() => _ShowResultsScreenState();
}

class _ShowResultsScreenState extends State<ShowResultsScreen> {
  String? _selectedOption = 'Low to High';
  final List<String> _filterOptions = ['Low to High', 'High to Low',];
  Future<Map<String, dynamic>>? _quotes; // Nullable Future
  late ApiService _apiService;
  String? airportId;
  String airportName = 'defaultAirportName';
  String startDate = 'defaultStartDate';
  String endDate = 'defaultEndDate';
  String startTime = 'defaultStartTime';
  String endTime = 'defaultEndTime';
  late Future<List<Map<String, dynamic>>> _airportData;

  @override
  void initState() {
    super.initState();
    _airportData = GetAirports.fetchAirports();
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

          // Separate recommended and non-recommended companies
          final recommendedCompanies = companies.where((a) => a['recommended'] == "Yes").toList();
          final otherCompanies = companies.where((a) => a['recommended'] != "Yes").toList();

          // Apply sorting based on the selected filter
          if (_selectedOption == 'Low to High') {
            recommendedCompanies.sort((a, b) => double.parse(a['price'].toString()).compareTo(double.parse(b['price'].toString())));
            otherCompanies.sort((a, b) => double.parse(a['price'].toString()).compareTo(double.parse(b['price'].toString())));
          } else if (_selectedOption == 'High to Low') {
            recommendedCompanies.sort((a, b) => double.parse(b['price'].toString()).compareTo(double.parse(a['price'].toString())));
            otherCompanies.sort((a, b) => double.parse(b['price'].toString()).compareTo(double.parse(a['price'].toString())));
          } else if (_selectedOption == 'Recommended') {
            // Show only recommended companies if "Recommended" is selected
            data['companies'] = recommendedCompanies;
            return data;
          }
          // Combine lists, placing recommended companies first
          data['companies'] = [...recommendedCompanies, ...otherCompanies];
          return data;
        });

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textScale = MediaQuery.of(context).textScaleFactor;

    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          _showNoInternetDialog(context);
        }

        return  Scaffold(
          appBar: AppBar(
            title: const Text('Available Company'),
            surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
      },
    );
  }
  void _showNoInternetDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoInternetDialog(
          checkConnectivity: () {
            Provider.of<ConnectivityProvider>(context, listen: false).checkConnectivity();
          },
        ),
      );
    });
  }

  Widget _buildAirportCard(BuildContext context, String startDate, String endDate, String startTime, String endTime, String airportName, Map<String, dynamic> offer) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, airportName),
            const SizedBox(height: 8),
            _buildDateTimeRow(startDate, startTime, endDate, endTime),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String airportName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildIconContainer(Icons.airplanemode_active, context),
            const SizedBox(width: 8),
            Text(
              airportName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow(
      String startDate, String startTime, String endDate, String endTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateTimeColumn(startDate, startTime, 'assets/map_blue.svg',
            const Color(0xFF1D9DD9)),
        _buildDateTimeColumn(
            endDate, endTime, 'assets/map.svg', const Color(0xFF33D91D)),
      ],
    );
  }

  Widget _buildDateTimeColumn(
      String date, String time, String asset, Color color) {
    return Row(
      children: [
        _buildIconContainerWithAsset(asset, color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            Text(time, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildIconContainer(IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildIconContainerWithAsset(String asset, Color color) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color.withOpacity(0.20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SvgPicture.asset(asset),
      ),
    );
  }





  Widget _buildOffersList(BuildContext context, String startDate, String endDate, String startTime, String endTime,) {

    double screenWidth = MediaQuery.of(context).size.width;

    double aspectRatio = screenWidth < 600
        ? 0.5  // For smaller screens (mobile)
        : 0.7; // For larger screens (tablet, desktop)
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
          ////print(snapshot.error);
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
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              childAspectRatio: aspectRatio,
            ),
            itemCount: companies.length, // Using the length of the companies list
            itemBuilder: (context, index) {
              final company = companies[index]; // Access each offer in the companies list
              return _buildOfferCard(company, context, totalDays!);
            },
          );
        }
      },
    );
  }
  Widget _buildOfferCard(dynamic offer, BuildContext context, String totalDays) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           _buildImageStack(offer),
            const SizedBox(height: 8),
            _buildOfferDetails(offer, context),
            const SizedBox(height: 8),
            _buildRatingRow(offer, context),
            const SizedBox(height: 8),
            _buildViewDetailsButton(context, offer),
            const SizedBox(height: 8),
            _buildPriceButton(context, offer, totalDays),
          ],
        ),
      ),
    );
  }

  Widget _buildImageStack(dynamic offer) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildImage(offer),
        ),
        if (offer['recommended'] == 'Yes')
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              color: Colors.red.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Marquee(
                text: '🔥 Recommended 🔥 Limited Time Offer!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                scrollAxis: Axis.horizontal,
                blankSpace: 50.0,
                velocity: 30.0,
                pauseAfterRound: Duration(seconds: 1),
                startPadding: 10.0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOfferDetails(dynamic offer, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildRatingRow(dynamic offer, BuildContext context) {
    final reviews = offer['reviews'] as List? ?? [];
    final rating = reviews.isNotEmpty && reviews[0]['rating'] != null ? reviews[0]['rating'].toString() : 'No rating';

    return Row(
      children: [
        Text(
          rating,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (reviews.isNotEmpty && reviews[0]['rating'] != null)
          ...List.generate(
            reviews[0]['rating'],
                (index) => InkWell(
              onTap: () => _showCupertinoRatingDialog(context, offer),
              child: const Icon(Icons.star, color: Colors.yellow, size: 20),
            ),
          ),
        const SizedBox(width: 4),
        if (reviews.isNotEmpty)
          Text(
            '(${reviews.length})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildViewDetailsButton(BuildContext context, dynamic offer) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewDeatils(company: offer)),
        );
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 30),
        side: const BorderSide(color: Colors.red, width: 1),
      ),
      child: const Text('View Details'),
    );
  }

  Widget _buildPriceButton(BuildContext context, dynamic offer, String totalDays) {
    final double originalPrice = double.tryParse(offer['price'] ?? '0') ?? 0;
    final double increasedPrice = originalPrice + 10;
    final bool isDbPrice = offer['park_api'] == 'DB';

    return Stack(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  company: offer,
                  totalDays: totalDays,
                  startDate: startDate,
                  endDate: endDate,
                  startTime: startTime,
                  endTime: endTime,
                  airportId: airportId!,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 35),
            backgroundColor: Colors.red,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '£${originalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white,
                ),
              ),
              if (isDbPrice) ...[
                const SizedBox(width: 4),
                Text(
                  '£${increasedPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    color: Colors.white.withOpacity(0.7),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (offer['recommended'] == 'Yes')
          Positioned(
            top: -2,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Best Value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }


  void _showCupertinoRatingDialog(BuildContext context, dynamic offer) {
    dynamic reviews = offer['reviews'];
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("User Ratings"),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: CupertinoScrollbar(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final user = reviews[index];
                  final String name = user["first_name"] ?? "N/A";
                  final String lastName = user["last_name"] ?? "";
                  final int rating = user["rating"] ?? 0;
                  final double ratingDouble = rating.toDouble();
                  final String comment = user["comments"] ?? "No comment";
                  return  Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.darkBackgroundColor, width: .5),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  name![0], // Use first letter, safe due to default value
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('$name $lastName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          RatingBarIndicator(
                            rating: ratingDouble!,
                            itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(height: 8),
                          Text(
                            comment!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage( offer) {
    if (offer['park_api'] == 'DB') {
      return CachedNetworkImage(
        imageUrl: 'https://airportparkbooking.uk/storage/${offer['logo']}',
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else if (offer['park_api'] == 'holiday') {
      return CachedNetworkImage(
        imageUrl: offer['logo'],
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else {
      return _errorImageWidget();
    }
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
