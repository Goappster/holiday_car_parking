import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holidayscar/screens/booking.dart';
import 'package:holidayscar/utils/ui_helper_date.dart';
import 'package:holidayscar/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/get_airports.dart';
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

  // Initialize variables with temporary default values
  String? airportId;
  String airportName = 'defaultAirportName';
  String startDate = 'defaultStartDate';
  String endDate = 'defaultEndDate';
  String startTime = 'defaultStartTime';
  String endTime = 'defaultEndTime';
  late Future<List<Map<String, dynamic>>> _airportData;
  int? _selectedAirportId;
  String? _selectedAirportName;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Results'),
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                    _showSetupDialog(context);
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
                        Text(startDate),
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
                        Text(endDate),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: _buildImage(offer),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: offer['recommended'] == 'Yes'
                          ? Container(
                        height: 20, // Fixed height for the banner
                        color: Colors.red.withOpacity(0.9),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Marquee(
                          text: '🔥 Recommended 🔥  Limited Time Offer!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          scrollAxis: Axis.horizontal, // Scroll left to right
                          crossAxisAlignment: CrossAxisAlignment.center,
                          blankSpace: 50.0, // Space between repeats
                          velocity: 30.0, // Speed of scrolling
                          pauseAfterRound: Duration(seconds: 1), // Pause before repeating
                          startPadding: 10.0,
                        ),
                      )
                          : SizedBox(), // Empty widget if the condition is false
                    ),

                  ],
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
                      for (int i = 0; i < offer['reviews'][0]['rating']; i++)
                        InkWell(
                          onTap: () {
                            _showCupertinoRatingDialog(context, offer);
                          },
                            child: const Icon(Icons.star, color: Colors.yellow, size: 20)),
                    ],
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    if (offer['reviews'] != null &&
                        offer['reviews'] is List &&
                        (offer['reviews'] as List).isNotEmpty &&
                        offer['reviews'][0]['rating'] != null)
                      ...[
                        Text(
                          '(${offer['reviews'].length ?? ''} )',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],

                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewDeatils(company: offer,)));
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 30),
                    // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),

                    side: BorderSide(color: Colors.red, width:1), // Red border
                  ),
                  child: Text(
                    'View Details',
                  ),
                ),
                Stack(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  BookingScreen(
                              company: offer,
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 35),
                        backgroundColor: Colors.red, // Button background color
                      ),
                      child: Builder(
                        builder: (context) {
                          double originalPrice = double.tryParse(offer['price'] ?? '0') ?? 0; // Convert price safely
                          double increasedPrice = originalPrice + 10; // Add £10
                          double discountedPrice = increasedPrice * 0.9; // Apply 10% discount
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Discounted Price (Final Price After Add & Discount)
                            Text(
                                '£${originalPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                  color: Colors.white, // White text for contrast
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01, // Adjust width dynamically
                              ),
                              Visibility(
                                visible: offer['park_api'] == 'DB',
                                child: Text(
                                  '£${increasedPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.03, // Adjust font size dynamically
                                    color: Colors.white.withOpacity(0.7), // Faded text color
                                    decoration: TextDecoration.lineThrough, // Strikethrough effect
                                  ),
                                ),
                              )


                            ],
                          );
                        },
                      ),
                    ),
                    if (offer['recommended'] == 'Yes')
                      Positioned(
                        top: -2,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
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
                )
              ],
            ),
          ),
        ],
      ),
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
                      side: BorderSide(color: Colors.grey.shade300, width: .5),
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


  TimeOfDay? _selectedStartTime, _selectedEndTime;
  DateTime? _pickupDate;
  DateTime? _dropOffDate;
  void _showDatePicker(BuildContext context, bool isPickup) {
    DateTime now = DateTime.now();
    DateTime initialDate = DateTime(now.year, now.month, now.day);
    DateTime selectedDate = isPickup ? (_pickupDate ?? initialDate) : (_dropOffDate ?? initialDate);

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          height: 300,
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(
            children: [
              _buildCupertinoToolbar(context, isPickup, selectedDate),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate, // 
                  minimumDate: initialDate,
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    setStateModal(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (isPickup) {
                      _pickupDate = selectedDate;
                    } else {
                      _dropOffDate = selectedDate;
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCupertinoToolbar(BuildContext context, bool isPickup, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoButton(
            child: const Text("Done", style: TextStyle(color: Colors.blue)),
            onPressed: () {
              setState(() {
                if (isPickup) {
                  _pickupDate = selectedDate;
                } else {
                  _dropOffDate = selectedDate;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  void _onFindParkingPressed() {
    Navigator.pop(context);
    if (_selectedStartTime == null || _selectedEndTime == null || _pickupDate == null || _dropOffDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all inputs.')));
      return;
    }



    _quotes = _apiService.fetchQuotes(
      airportId: airportId!,
      dropDate: UiHelperDate.formatDate(_dropOffDate),
      dropTime:  UiHelperDate.formatTime(_selectedStartTime),
      pickDate:  UiHelperDate.formatDate(_pickupDate),
      pickTime: UiHelperDate.formatTime(_selectedEndTime),
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
    // Navigator.pushNamed(context, '/ShowResult',
    //   arguments: {
    //     'startDate': UiHelperDate.formatDate(_pickupDate),
    //     'endDate': UiHelperDate.formatDate(_dropOffDate),
    //     'startTime': UiHelperDate.formatTime(_selectedStartTime),
    //     'endTime': UiHelperDate.formatTime(_selectedEndTime),
    //     'AirportId': _selectedAirportId.toString(),
    //     'AirportName': _selectedAirportName,
    //   },
    // );
  }





  void _showSetupDialog(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkTheme ? AppTheme.darkSurfaceColor : Colors.grey[300]!;
    final highlightColor = isDarkTheme ? AppTheme.darkTextSecondaryColor : Colors.grey[100]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Add StatefulBuilder for real-time updates
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Text("Setup Options"),
              content: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _airportData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Shimmer.fromColors(
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                              child: Container(
                                width: double.infinity,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No airports available');
                          } else {
                            final airports = snapshot.data!;
                            return InkWell(
                              onTap: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (_) => CupertinoActionSheet(
                                    title: const Text("Select Airport"),
                                    actions: [
                                      SizedBox(
                                        height: 200,
                                        child: CupertinoPicker(
                                          itemExtent: 60.0,
                                          onSelectedItemChanged: (int index) {
                                            setState(() {
                                              _selectedAirportId = airports[index]['id'];
                                              _selectedAirportName = airports[index]['name'];
                                            });
                                          },
                                          children: airports.map((airport) {
                                            return Center(
                                              child: Text(airport['name']),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: const Text("Done"),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      const Icon(MingCute.airplane_line, color: Colors.red),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(_selectedAirportName ?? "Select Airport"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      UiHelperDate.buildContainer(
                        label: "Drop-off Date",
                        value: UiHelperDate.formatDate(_dropOffDate),
                        onTap: () => _showDatePicker(context, false),
                        icon: Icons.event,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      UiHelperDate.buildContainer(
                        label: "Pickup Date",
                        value: UiHelperDate.formatDate(_pickupDate),
                        onTap: () => _showDatePicker(context, true),
                        icon: Icons.calendar_today,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: UiHelperDate.buildContainer(
                              label: "Drop-Off Time",
                              value: UiHelperDate.formatTimeOfDay(_selectedStartTime),
                              onTap: () async {
                                final time = await _selectTime(context, true);
                                setState(() {
                                  _selectedStartTime;
                                });
                              },
                              icon: Icons.access_time,
                              context: context,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: UiHelperDate.buildContainer(
                              label: "Pick-up Time",
                              value: UiHelperDate.formatTimeOfDay(_selectedEndTime),
                              onTap: () async {
                                final time = await _selectTime(context, false);
                                  setState(() {
                                    _selectedEndTime;
                                  });

                              },
                              icon: Icons.timer,
                              context: context,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 49,
                        child: ElevatedButton(
                          onPressed: _onFindParkingPressed,
                          child: const Text('Find Parking'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
