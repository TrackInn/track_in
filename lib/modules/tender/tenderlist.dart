import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart'; // Ensure this import points to your base URL file
import 'package:track_in/modules/tender/tenderdetails.dart'; // Import the TenderDetails screen

void main() {
  runApp(Tenderlist());
}

class Tenderlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TenderScreen(),
    );
  }
}

class TenderScreen extends StatelessWidget {
  // Function to fetch tender list from the API
  Future<List<dynamic>> fetchTenderList() async {
    final response = await http.get(Uri.parse('$baseurl/tenderlist/'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body);
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
      return '${(parsedAmount / 10000000).toStringAsFixed(2)} CR';
    } else if (parsedAmount >= 100000) {
      // Convert to Lakhs
      return '${(parsedAmount / 100000).toStringAsFixed(2)} Lakh';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tender List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
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
                    final totalTenders = snapshot.data!['total_tenders'] ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total EMD",
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 5),
                          Text("Count: $totalTenders",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Amount:",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                  Text("₹${formatAmount(totalEMD)}",
                                      style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Pending Amount:",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                  Text("₹${formatAmount(pendingEMD)}",
                                      style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Search Bar and Filter Button
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        onChanged: (query) {
                          // Implement search functionality here
                          // You can filter the tender list based on the query
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Button
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_alt_rounded,
                        color: Colors.white),
                    label: const Text("Filter",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tender List
              Expanded(
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
                              tender['EMD_refund_status']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display each tender item
  Widget tenderlistitem(String title, String date, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
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
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.currency_rupee, color: color),
          ),
          title: Text(title, style: const TextStyle(color: Colors.black)),
          subtitle: Text(date, style: const TextStyle(color: Colors.black38)),
          trailing: Text(amount,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
