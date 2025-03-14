import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart';
import 'dart:convert';

import 'package:track_in/modules/tenderViewer/tender_manager.dart';
import 'package:track_in/modules/tenderViewer/tenderdetails.dart';

void main() {
  runApp(NotAwardedTenderList());
}

class NotAwardedTenderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotAwardedTenderScreen(),
    );
  }
}

class NotAwardedTenderScreen extends StatefulWidget {
  @override
  _NotAwardedTenderScreenState createState() => _NotAwardedTenderScreenState();
}

class _NotAwardedTenderScreenState extends State<NotAwardedTenderScreen> {
  List<dynamic> notAwardedTenderListData = [];
  List<dynamic> filteredNotAwardedTenderListData = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  // Variables for sorting and filtering
  String sortBy = 'title'; // Default sorting by title
  bool isAscending = true; // Default sorting order
  bool isFilterApplied = false; // Track if filters are applied

  @override
  void initState() {
    super.initState();
    fetchNotAwardedTenders();
  }

  Future<void> fetchNotAwardedTenders() async {
    final response = await http.get(
      Uri.parse('$baseurl/tendernotawardedlist/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        notAwardedTenderListData = json.decode(response.body);
        filteredNotAwardedTenderListData = List.from(notAwardedTenderListData);
        isLoading = false;
        _sortTenders(); // Apply default sorting after fetching data
      });
    } else {
      throw Exception('Failed to load not awarded tenders');
    }
  }

  void filterNotAwardedTenders(String query) {
    setState(() {
      filteredNotAwardedTenderListData = notAwardedTenderListData
          .where((tender) =>
              tender['tender_title']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              tender['tender_id'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      _sortTenders(); // Apply sorting after filtering
    });
  }

  void _sortTenders() {
    setState(() {
      switch (sortBy) {
        case 'title':
          filteredNotAwardedTenderListData.sort((a, b) => isAscending
              ? a['tender_title'].compareTo(b['tender_title'])
              : b['tender_title'].compareTo(a['tender_title']));
          break;
        case 'id':
          filteredNotAwardedTenderListData.sort((a, b) => isAscending
              ? a['tender_id'].compareTo(b['tender_id'])
              : b['tender_id'].compareTo(a['tender_id']));
          break;
        case 'status':
          filteredNotAwardedTenderListData.sort((a, b) => isAscending
              ? a['bid_outcome'].compareTo(b['bid_outcome'])
              : b['bid_outcome'].compareTo(a['bid_outcome']));
          break;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      sortBy = 'title'; // Reset to default sorting
      isAscending = true; // Reset to default order
      isFilterApplied = false; // Indicate no filters are applied
      _sortTenders(); // Reapply sorting
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // Set background color to white
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort & Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sort By Dropdown
                  DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'title',
                        child: Text('Title'),
                      ),
                      DropdownMenuItem(
                        value: 'id',
                        child: Text('ID'),
                      ),
                      DropdownMenuItem(
                        value: 'status',
                        child: Text('Status'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortBy = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Sort Order Toggle
                  Row(
                    children: [
                      const Text(
                        'Sort Order:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Switch(
                        value: isAscending,
                        onChanged: (value) {
                          setState(() {
                            isAscending = value;
                          });
                        },
                      ),
                      Text(
                        isAscending ? 'Ascending' : 'Descending',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Apply and Clear Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _sortTenders(); // Apply sorting
                            Navigator.pop(context); // Close the bottom sheet
                            setState(() {
                              isFilterApplied =
                                  true; // Indicate filters are applied
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _clearFilters(); // Clear filters
                            Navigator.pop(context); // Close the bottom sheet
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    // Search Bar
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
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (query) {
                          filterNotAwardedTenders(query);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Dynamic Filter Button
                    IconButton(
                      icon: Stack(
                        children: [
                          Icon(Icons.filter_list, color: Colors.white),
                          if (isFilterApplied)
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        _showFilterBottomSheet(
                            context); // Show filter bottom sheet
                      },
                    ),
                  ],
                ),
              ),
              // Total Not Awarded Tenders Box
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${notAwardedTenderListData.length}', // Total tenders count
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Tenders Not Awarded',
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
              // Not Awarded Tender List
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: ListView(
                          children:
                              filteredNotAwardedTenderListData.map((tender) {
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
                              child: notAwardedTenderListItem(
                                tender['tender_title'] ?? 'No Title',
                                tender['tender_id'] ?? 'No ID',
                                tender['bid_outcome'] ?? 'No Status',
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

  // Widget to display each not awarded tender item
  Widget notAwardedTenderListItem(String title, String id, String status) {
    Color statusColor = Colors.grey; // Default color for unknown status
    if (status == 'lost') {
      statusColor = Colors.red;
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
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: Offset(0, 1),
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

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
