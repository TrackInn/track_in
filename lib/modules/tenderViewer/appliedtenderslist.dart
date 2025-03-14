import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart';
import 'dart:convert';

import 'package:track_in/modules/tenderViewer/tender_manager.dart';
import 'package:track_in/modules/tenderViewer/tenderdetails.dart';

void main() {
  runApp(AppliedTenderList());
}

class AppliedTenderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppliedTenderScreen(),
    );
  }
}

class AppliedTenderScreen extends StatefulWidget {
  @override
  _AppliedTenderScreenState createState() => _AppliedTenderScreenState();
}

class _AppliedTenderScreenState extends State<AppliedTenderScreen> {
  List<dynamic> appliedTenderListData = [];
  List<dynamic> filteredAppliedTenderListData = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAppliedTenders();
  }

  Future<void> fetchAppliedTenders() async {
    final response = await http.get(
      Uri.parse('$baseurl/appliedtenders/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        appliedTenderListData = json.decode(response.body);
        filteredAppliedTenderListData =
            List.from(appliedTenderListData); // Initialize filtered list
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load applied tenders');
    }
  }

  void filterAppliedTenders(String query) {
    setState(() {
      filteredAppliedTenderListData = appliedTenderListData
          .where((tender) =>
              tender['tender_title']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              tender['tender_id'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
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
                color: Colors.blue,
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
                    //Search bar
                    Expanded(
                      child: TextField(
                        controller: searchController,
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
                          filterAppliedTenders(query);
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
              // Total Applied Tenders Box
              Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${appliedTenderListData.length}', // Total tenders count
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Applied Tenders',
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
              // Applied Tender List
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: ListView(
                          children: filteredAppliedTenderListData.map((tender) {
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
                              child: appliedTenderListItem(
                                tender['tender_title'] ?? 'No Title',
                                tender['tender_id'] ?? 'No ID',
                                tender['tender_status'] ?? 'No Status',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display each applied tender item
  Widget appliedTenderListItem(String title, String id, String status) {
    Color statusColor = Colors.grey; // Default color for unknown status
    if (status == 'applied') {
      statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        width: double.infinity,
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
            child: Icon(Icons.assignment, color: statusColor),
          ),
          title: Text(title, style: const TextStyle(color: Colors.black)),
          subtitle:
              Text("ID: $id", style: const TextStyle(color: Colors.black38)),
          trailing: Text(
            capitalize(status), // Capitalize the status
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
