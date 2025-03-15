import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart'; // Ensure this import points to your base URL file
import 'dart:convert';
import 'package:track_in/modules/internal_license_viewer/internal_viewer_licence_details.dart'; // Ensure this import points to your LicenseDetailScreen

class InternalViewerLicenseList extends StatefulWidget {
  const InternalViewerLicenseList({super.key});

  @override
  _InternalViewerLicenseListState createState() =>
      _InternalViewerLicenseListState();
}

class _InternalViewerLicenseListState extends State<InternalViewerLicenseList> {
  List licenses = [];
  List filteredLicenses = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedApplicationType = 'All';
  String _selectedProductType = 'All';
  String _selectedClassOfDeviceType = 'All';
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
      final response = await http.get(Uri.parse('$baseurl/list/'));
      if (response.statusCode == 200) {
        setState(() {
          licenses = json.decode(response.body);
          filteredLicenses =
              licenses; // Initialize filteredLicenses with all licenses
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
        bool matchesClassOfDeviceType = _selectedClassOfDeviceType == 'All' ||
            license['class_of_device_type'] == _selectedClassOfDeviceType;
        bool matchesExpiryDate = true;
        if (_isExpiryFilterEnabled &&
            _selectedStartDate != null &&
            _selectedEndDate != null) {
          final expiryDate = DateTime.parse(license['expiry_date']);
          matchesExpiryDate = expiryDate.isAfter(_selectedStartDate!) &&
              expiryDate.isBefore(_selectedEndDate!);
        }
        return matchesApplicationType &&
            matchesProductType &&
            matchesClassOfDeviceType &&
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

  void _clearFilters() {
    setState(() {
      _selectedApplicationType = 'All';
      _selectedProductType = 'All';
      _selectedClassOfDeviceType = 'All';
      _isExpiryFilterEnabled = false;
      _selectedStartDate = null;
      _selectedEndDate = null;
      filteredLicenses = licenses; // Reset to show all licenses
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
          // Display applied filters in a capsule-like structure
          if (_selectedApplicationType != 'All' ||
              _selectedProductType != 'All' ||
              _selectedClassOfDeviceType != 'All' ||
              _isExpiryFilterEnabled)
            AppliedFiltersChips(
              applicationType: _selectedApplicationType,
              productType: _selectedProductType,
              classOfDeviceType: _selectedClassOfDeviceType,
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
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
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
                  setModalState(() {
                    _selectedApplicationType = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Application Type'),
              ),
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
                value: _selectedClassOfDeviceType,
                items: ['All', 'Device1', 'Device2', 'Device3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    _selectedClassOfDeviceType = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Class of Device Type'),
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

  Widget _buildLicenseCard(BuildContext context, Map data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InternalViewerLicenseDetails(data: data),
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

// Widget to display applied filters in a capsule-like structure
class AppliedFiltersChips extends StatelessWidget {
  final String applicationType;
  final String productType;
  final String classOfDeviceType;
  final bool isExpiryFilterEnabled;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onClearFilters;

  const AppliedFiltersChips({
    required this.applicationType,
    required this.productType,
    required this.classOfDeviceType,
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
          if (applicationType != 'All')
            _buildFilterChip('Application: $applicationType'),
          if (productType != 'All') _buildFilterChip('Product: $productType'),
          if (classOfDeviceType != 'All')
            _buildFilterChip('Device: $classOfDeviceType'),
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
