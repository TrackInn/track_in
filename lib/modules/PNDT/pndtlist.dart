import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart';
import 'pndt_details.dart'; // Import the PndtDetails screen

class Pndtlist extends StatefulWidget {
  @override
  _LicenseListPageState createState() => _LicenseListPageState();
}

class _LicenseListPageState extends State<Pndtlist> {
  List<Map<String, dynamic>> licenses = [];
  List<Map<String, dynamic>> filteredLicenses = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLicenses();
  }

  Future<void> fetchLicenses() async {
    try {
      final response = await http.get(Uri.parse('$baseurl/listpndtlicense/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          licenses = data.map<Map<String, dynamic>>((item) {
            return {
              "license_number": item['license_number'] ?? 'No License Number',
              "application_number":
                  item['application_number'] ?? 'No Application Number',
              "submission_date":
                  item['submission_date'] ?? 'No Submission Date',
              "expiry_date": item['expiry_date'] ?? 'No Expiry Date',
              "approval_date": item['approval_date'] ?? 'No Approval Date',
              "product_type": item['product_type'] ?? 'No Product Type',
              "product_name": item['product_name'] ?? 'No Product Name',
              "model_number": item['model_number'] ?? 'No Model Number',
              //"state": item['state'] ?? 'No State',
              "intended_use": item['intended_use'] ?? 'No Intended Use',
              "class_of_device":
                  item['class_of_device'] ?? 'No Class of Device',
              "software": item['software'] ?? false,
              "legal_manufacturer":
                  item['legal_manufacturer'] ?? 'No Legal Manufacturer',
              "authorize_agent_address": item['authorize_agent_address'] ??
                  'No Authorized Agent Address',
              "attachments": item['attachments'] ?? 'No Attachments',
            };
          }).toList();
          filteredLicenses = licenses;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load licenses');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredLicenses = licenses
          .where((license) => license["product_name"]!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filter Options",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Sort by License Number"),
                onTap: () {
                  setState(() {
                    filteredLicenses.sort((a, b) =>
                        a["license_number"]!.compareTo(b["license_number"]!));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Sort by Name"),
                onTap: () {
                  setState(() {
                    filteredLicenses.sort((a, b) =>
                        a["product_name"]!.compareTo(b["product_name"]!));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Licenses"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: filterSearch,
                      decoration: InputDecoration(
                        hintText: "Search Licenses...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 28),
                    onPressed: showFilterOptions,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: filteredLicenses.length,
                        itemBuilder: (context, index) {
                          return buildLicenseCard(
                            context,
                            filteredLicenses[index],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLicenseCard(
      BuildContext context, Map<String, dynamic> licenseData) {
    double cardWidth = MediaQuery.of(context).size.width * 0.48;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PndtDetails(licenseData: licenseData),
          ),
        );
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
                licenseData['product_name'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${licenseData['license_number']}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
