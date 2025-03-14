import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';
import 'pndt_details.dart'; // Import the PndtDetails screen

class Pndtlist extends StatefulWidget {
  @override
  _PndtlistState createState() => _PndtlistState();
}

class _PndtlistState extends State<Pndtlist> {
  List<Map<String, dynamic>> licenses = [];
  List<Map<String, dynamic>> filteredLicenses = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedProductType = 'All';
  String _selectedState = 'All';
  bool _isExpiryFilterEnabled = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

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
              "state": item['state'] ?? 'No State',
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

  void _filterLicenses() {
    setState(() {
      filteredLicenses = licenses.where((license) {
        bool matchesProductType = _selectedProductType == 'All' ||
            license['product_type'] == _selectedProductType;
        bool matchesState =
            _selectedState == 'All' || license['state'] == _selectedState;
        bool matchesExpiryDate = true;
        if (_isExpiryFilterEnabled &&
            _selectedStartDate != null &&
            _selectedEndDate != null) {
          final expiryDate = DateTime.parse(license['expiry_date']);
          matchesExpiryDate = expiryDate.isAfter(_selectedStartDate!) &&
              expiryDate.isBefore(_selectedEndDate!);
        }
        return matchesProductType && matchesState && matchesExpiryDate;
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

  void _clearFilters() {
    setState(() {
      _selectedProductType = 'All';
      _selectedState = 'All';
      _isExpiryFilterEnabled = false;
      _selectedStartDate = null;
      _selectedEndDate = null;
      filteredLicenses = licenses; // Reset to show all licenses
    });
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
                  const SizedBox(width: 8),
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
            if (_selectedProductType != 'All' ||
                _selectedState != 'All' ||
                _isExpiryFilterEnabled)
              AppliedFiltersChips(
                productType: _selectedProductType,
                state: _selectedState,
                isExpiryFilterEnabled: _isExpiryFilterEnabled,
                startDate: _selectedStartDate,
                endDate: _selectedEndDate,
                onClearFilters: _clearFilters,
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredLicenses.isEmpty
                      ? const Center(child: Text('No licenses found.'))
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

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                items: ['All', 'Product1', 'Product2', 'Product3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    _selectedProductType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Product Type'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedState,
                items:
                    ['All', 'State1', 'State2', 'State3'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    _selectedState = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'State'),
              ),
              SwitchListTile(
                title: const Text('Enable Expiry Date Filter'),
                value: _isExpiryFilterEnabled,
                onChanged: (value) {
                  setModalState(() {
                    _isExpiryFilterEnabled = value;
                  });
                },
              ),
              if (_isExpiryFilterEnabled) ...[
                InkWell(
                  onTap: () async {
                    final DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedStartDate != null) {
                      setModalState(() {
                        _selectedStartDate = pickedStartDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    child: Text(
                      _selectedStartDate == null
                          ? 'Select Start Date'
                          : '${_selectedStartDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final DateTime? pickedEndDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedEndDate != null) {
                      setModalState(() {
                        _selectedEndDate = pickedEndDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'End Date'),
                    child: Text(
                      _selectedEndDate == null
                          ? 'Select End Date'
                          : '${_selectedEndDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ),
              ],
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
      },
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

// Widget to display applied filters in a capsule-like structure
class AppliedFiltersChips extends StatelessWidget {
  final String productType;
  final String state;
  final bool isExpiryFilterEnabled;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onClearFilters;

  const AppliedFiltersChips({
    required this.productType,
    required this.state,
    required this.isExpiryFilterEnabled,
    this.startDate,
    this.endDate,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (productType != 'All') _buildFilterChip('Product: $productType'),
          if (state != 'All') _buildFilterChip('State: $state'),
          if (isExpiryFilterEnabled && startDate != null && endDate != null)
            _buildFilterChip(
                'Expiry: ${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}'),
          InkWell(
            onTap: onClearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}
