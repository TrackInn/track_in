import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart';

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

  List<Map<String, String>> recentlyAddedPndtItems = [];
  List<Map<String, String>> recentlyViewedPndtItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentlyAddedPndt();
    _fetchRecentlyViewedPndt();
  }

  Future<void> _fetchRecentlyAddedPndt() async {
    final response = await http
        .get(Uri.parse('$baseurl/recentlyadded/?filter=$_selectedFilter'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recentlyAddedPndtItems = [
          for (var pndtLicense in data['recent_pndt_licenses'])
            {
              "name": pndtLicense["product_name"],
              "number": pndtLicense["application_number"]
            },
        ];
      });
    } else {
      print(
          'Failed to load recently added PNDT licenses: ${response.statusCode}');
    }
  }

  Future<void> _fetchRecentlyViewedPndt() async {
    final response = await http.get(Uri.parse('$baseurl/recentlyviewed/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recentlyViewedPndtItems = [
          for (var pndtLicense in data['recently_viewed_pndt_licenses'])
            {
              "name": pndtLicense["product_name"],
              "number": pndtLicense["application_number"]
            },
        ];
      });
    } else {
      print(
          'Failed to load recently viewed PNDT licenses: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("PNDT License List"),
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
                    _fetchRecentlyAddedPndt();
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: _showRecentlyAdded
                    ? recentlyAddedPndtItems.length
                    : recentlyViewedPndtItems.length,
                itemBuilder: (context, index) {
                  final item = _showRecentlyAdded
                      ? recentlyAddedPndtItems[index]
                      : recentlyViewedPndtItems[index];
                  return _buildPndtLicenseCard(context, item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card design for PNDT Licenses
  Widget _buildPndtLicenseCard(BuildContext context, Map<String, String> data) {
    double cardWidth = MediaQuery.of(context).size.width * 0.48;

    return GestureDetector(
      onTap: () {
        // Handle card tap if needed
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: cardWidth - 24,
              child: Text(
                data["name"]!, // Display product_name
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${data["number"]}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
