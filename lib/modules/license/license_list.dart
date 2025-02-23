import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart'; // Ensure this import points to your base URL file
import 'dart:convert';
import 'package:track_in/modules/license/license_details.dart'; // Ensure this import points to your LicenseDetailScreen

void main() {
  runApp(const LicenseListApp());
}

class LicenseListApp extends StatelessWidget {
  const LicenseListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LicenseListScreen(),
    );
  }
}

class LicenseListScreen extends StatefulWidget {
  const LicenseListScreen({super.key});

  @override
  _LicenseListScreenState createState() => _LicenseListScreenState();
}

class _LicenseListScreenState extends State<LicenseListScreen> {
  List licenses = [];
  List filteredLicenses = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedApplicationType = 'All';
  String _selectedProductType = 'All';
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    fetchLicenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchLicenses() async {
    try {
      final response = await http.get(Uri.parse('$baseurl/list/'));
      if (response.statusCode == 200) {
        setState(() {
          licenses = json.decode(response.body);
          filteredLicenses = licenses;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load licenses: ${response.statusCode}'),
          ),
        );
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

  void _filterLicenses() {
    setState(() {
      filteredLicenses = licenses.where((license) {
        bool matchesApplicationType = _selectedApplicationType == 'All' ||
            license['application_type'] == _selectedApplicationType;
        bool matchesProductType = _selectedProductType == 'All' ||
            license['product_type'] == _selectedProductType;
        bool matchesExpiryDate = _selectedExpiryDate == null ||
            DateTime.parse(license['expiry_date'])
                .isBefore(_selectedExpiryDate!);
        return matchesApplicationType &&
            matchesProductType &&
            matchesExpiryDate;
      }).toList();
    });
  }

  void _searchLicenses(String query) {
    setState(() {
      filteredLicenses = licenses.where((license) {
        return license['product_name']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            license['license_number']
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Flexible widget to prevent overflow
                Flexible(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                hintText: "Search here...",
                                border: InputBorder.none,
                              ),
                              onChanged: _searchLicenses,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Spacing between search and filter
                // Filter Button
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return _buildFilterBottomSheet();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLicenses.isEmpty
                    ? const Center(child: Text('No licenses found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredLicenses.length,
                        itemBuilder: (context, index) {
                          var license = filteredLicenses[index];
                          return _buildLicenseCard(context, license);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedApplicationType,
            items: ['All', 'Type1', 'Type2', 'Type3'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedApplicationType = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Application Type'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedProductType,
            items:
                ['All', 'Product1', 'Product2', 'Product3'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductType = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Product Type'),
          ),
          InkWell(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedExpiryDate = pickedDate;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Expiry Date'),
              child: Text(
                _selectedExpiryDate == null
                    ? 'Select Date'
                    : '${_selectedExpiryDate!.toLocal()}'.split(' ')[0],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _filterLicenses();
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseCard(BuildContext context, Map data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LicenseDetailScreen(data: data),
          ),
        ).then(
          (value) {
            fetchLicenses();
          },
        );
      },
      child: Container(
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
                  data['product_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "License No: ${data['license_number'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
