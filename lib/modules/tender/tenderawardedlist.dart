import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart'; // Ensure this import points to your base URL file
import 'package:track_in/modules/tender/tender_manager.dart';
import 'package:track_in/modules/tender/tenderdetails.dart'; // Import the TenderDetails screen

void main() {
  runApp(AwardedTenderListView());
}

class AwardedTenderListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AwardedTenderList(),
    );
  }
}

class AwardedTenderList extends StatelessWidget {
  // Function to fetch awarded tender list from the API
  Future<List<dynamic>> fetchAwardedTenderList() async {
    final response = await http.get(Uri.parse('$baseurl/awardedtenders/'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> tenders = json.decode(response.body);
      return tenders;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load awarded tender list');
    }
  }

  // Function to capitalize the first letter of a string
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Changed to blue
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navbar with back arrow, search bar, and filter button
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: Colors.blue, // Changed to blue
                child: Row(
                  children: [
                    // Back Arrow
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Navigate to TenderManager screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TenderManager(),
                          ),
                        );
                      },
                    ),
                    // Search Bar
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.black45),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.only(top: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (query) {
                          // Implement search functionality here
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    // Filter Button
                    IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        // Add filter functionality here
                      },
                    ),
                  ],
                ),
              ),
              // Total Awarded Tenders Box
              Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Changed to blue
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      FutureBuilder<List<dynamic>>(
                        future: fetchAwardedTenderList(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(
                                color: Colors.white);
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.white));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('No data available',
                                style: TextStyle(color: Colors.white));
                          } else {
                            return Text(
                              '${snapshot.data!.length}', // Total tenders count
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                      Text(
                        'Awarded Tenders',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Awarded Tender List
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchAwardedTenderList(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      } else {
                        return ListView(
                          children: snapshot.data!.map((tender) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to TenderDetails screen with the selected tender data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TenderDetails(data: tender),
                                  ),
                                );
                              },
                              child: tenderlistitem(
                                tender['tender_title'] ?? 'No Title',
                                tender['tender_id'] ?? 'No ID',
                                tender['bid_outcome'] ??
                                    'No Status', // Changed to bid_outcome
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display each tender item
  Widget tenderlistitem(String title, String date, String status) {
    Color statusColor = Colors.green; // Color for "won" status
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(Icons.assignment,
                color: statusColor), // Changed to tender icon
          ),
          title: Text(title, style: const TextStyle(color: Colors.black)),
          subtitle: Text(date, style: const TextStyle(color: Colors.black38)),
          trailing: Text(
            capitalize(status), // Capitalize the status (e.g., "won" -> "Won")
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
