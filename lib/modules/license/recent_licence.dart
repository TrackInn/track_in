import 'package:flutter/material.dart';
import 'package:track_in/baseurl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ToggleCardApp extends StatelessWidget {
  const ToggleCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToggleCardScreen(),
    );
  }
}

class ToggleCardScreen extends StatefulWidget {
  const ToggleCardScreen({super.key});

  @override
  _ToggleCardScreenState createState() => _ToggleCardScreenState();
}

class _ToggleCardScreenState extends State<ToggleCardScreen> {
  bool _showRecentlyAdded = true; // Toggle state
  String _selectedFilter = 'all'; // Filter state

  List<Map<String, String>> recentlyAddedItems = [];
  List<Map<String, String>> recentlyViewedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentlyAdded();
    _fetchRecentlyViewed();
  }

  Future<void> _fetchRecentlyAdded() async {
    final response = await http
        .get(Uri.parse('$baseurl/recentlyadded/?filter=$_selectedFilter'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Only use License data
        recentlyAddedItems = [
          for (var license in data['recent_licenses'])
            {
              "name": license["product_name"],
              "number": license["application_number"]
            },
        ];
      });
    }
  }

  Future<void> _fetchRecentlyViewed() async {
    final response = await http.get(Uri.parse('$baseurl/recentlyviewed/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Only use License data
        recentlyViewedItems = [
          for (var license in data['recently_viewed_licenses'])
            {
              "name": license["product_name"],
              "number": license["application_number"]
            },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("License List"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Toggle buttons for Recently Added and Recently Viewed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showRecentlyAdded = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _showRecentlyAdded ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Recently Added',
                          style: TextStyle(
                            color: _showRecentlyAdded
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showRecentlyAdded = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showRecentlyAdded
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Recently Viewed',
                          style: TextStyle(
                            color: !_showRecentlyAdded
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter dropdown for Recently Added
          if (_showRecentlyAdded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: DropdownButton<String>(
                value: _selectedFilter,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                    _fetchRecentlyAdded();
                  });
                },
                items: <String>[
                  'all',
                  'this_week',
                  'this_month',
                  'this_year',
                  'last_year'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          // List of cards based on the selected toggle
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _showRecentlyAdded
                  ? recentlyAddedItems.length
                  : recentlyViewedItems.length,
              itemBuilder: (context, index) {
                // Prioritize Recently Viewed when toggled
                final item = _showRecentlyAdded
                    ? recentlyAddedItems[index]
                    : recentlyViewedItems[index];
                return _buildLicenseCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Card design
  Widget _buildLicenseCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"]!, // Display product_name
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "License No: ${data["number"]}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
