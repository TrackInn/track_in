import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';
import 'package:track_in/modules/tenderViewer/tenderdetails.dart'; // Ensure this import points to your base URL file

void main() {
  runApp(Pendingemdlistview());
}

class Pendingemdlistview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Pendingemdlist(),
    );
  }
}

class Pendingemdlist extends StatelessWidget {
  // Function to fetch tender list from the API
  Future<List<dynamic>> fetchTenderList() async {
    final response = await http.get(Uri.parse('$baseurl/emd_refund_pending/'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> tenders = json.decode(response.body);
      return tenders;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load tender list');
    }
  }

  // Function to fetch total EMD amount, pending EMD amount, and total tenders
  Future<Map<String, dynamic>> fetchTotalEMD() async {
    final response = await http.get(Uri.parse('$baseurl/totalemdamount/'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load total EMD data');
    }
  }

  // Function to format large numbers into CR, Lakh, or K
  String formatAmount(dynamic amount) {
    // Convert the amount to double if it's not already
    double parsedAmount = amount is int ? amount.toDouble() : amount;

    if (parsedAmount >= 10000000) {
      // Convert to Crores
      return '${(parsedAmount / 10000000).toStringAsFixed(2)} Cr';
    } else if (parsedAmount >= 100000) {
      // Convert to Lakhs
      return '${(parsedAmount / 100000).toStringAsFixed(2)} L';
    } else if (parsedAmount >= 1000) {
      // Convert to Thousands
      return '${(parsedAmount / 1000).toStringAsFixed(2)} K';
    } else {
      // Show the amount as is
      return parsedAmount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
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
                        Navigator.pop(context);
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
              // EMD Pending Box
              FutureBuilder<Map<String, dynamic>>(
                future: fetchTotalEMD(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    final totalEMD = snapshot.data!['total_emd_amount'] ?? 0;
                    final pendingEMD =
                        snapshot.data!['total_pending_emd_amount'] ?? 0;
                    final totalPendingTenders =
                        snapshot.data!['total_pending_emd_count'] ?? 0;

                    return Center(
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
                              '$totalPendingTenders', // Display total pending tenders count
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'EMD Pending',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Amount:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '₹${formatAmount(totalEMD)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pending Amount:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '₹${formatAmount(pendingEMD)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Tender List
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
                    future: fetchTenderList(),
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
                                tender['EMD_amount'] ?? '₹0',
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
  Widget tenderlistitem(String title, String date, String amount) {
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
            backgroundColor: Colors.orange.withOpacity(0.2),
            child: Icon(Icons.currency_rupee, color: Colors.orange),
          ),
          title: Text(title, style: const TextStyle(color: Colors.black)),
          subtitle: Text(date, style: const TextStyle(color: Colors.black38)),
          trailing: Text(amount,
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
