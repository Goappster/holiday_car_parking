import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  String _searchQuery = '';
  final List<String> _recentSearches = [];
  final List<String> _popularCompanies = [
    'Purple Parking',
    'Holiday Parking',
    'Express Parking',
    'Secure Parking',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _recentSearches.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                }).followedBy(_popularCompanies.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                }));
              },
              onSelected: (String selection) {
                setState(() {
                  _controller.text = selection;
                  _searchQuery = selection.toLowerCase();
                  if (!_recentSearches.contains(selection)) {
                    _recentSearches.add(selection);
                  }
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                _controller = textEditingController;
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: HotOffersSection2(
                searchQuery: _searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HotOffersSection2 extends StatelessWidget {
  final String searchQuery;

  const HotOffersSection2({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final offers = [
      const OfferCard(
        title: 'Purple Parking',
        description: 'Purple Express Charge & Power...',
        rating: 4.7,
        price: '£45.40',
        imageSource: 'assets/images/purple.png',
      ),
      const OfferCard(
        title: 'Holiday Parking',
        description: 'Holiday Extras Express & Charge...',
        rating: 4.2,
        price: '£25.40',
        imageSource: 'assets/images/Express.png',
      ),
      const OfferCard(
        title: 'Purple Parking',
        description: 'Purple Express Charge & Power...',
        rating: 4.7,
        price: '£45.40',
        imageSource: 'assets/images/purple.png',
      ),
      const OfferCard(
        title: 'Purple Parking',
        description: 'Purple Express Charge & Power...',
        rating: 4.7,
        price: '£45.40',
        imageSource: 'assets/images/purple.png',
      ),
    ];

    final filteredOffers = offers.where((offer) {
      return offer.title.toLowerCase().contains(searchQuery) ||
             offer.description.toLowerCase().contains(searchQuery);
    }).toList();

    return ListView(
      scrollDirection: Axis.vertical,
      children: filteredOffers,
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
    return Card(
      child: Column(
        children: [
          Image.asset(imageSource),
          Text(title),
          Text(description),
          Text('Rating: $rating'),
          Text('Price: $price'),
        ],
      ),
    );
  }
}
