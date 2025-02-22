import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart';
import 'dart:convert';

import 'package:track_in/modules/license/license_details.dart';
import 'package:track_in/profile.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLicenses();
  }

  Future<void> fetchLicenses() async {
    try {
      final response = await http.get(Uri.parse('$baseurl/list/'));
      if (response.statusCode == 200) {
        setState(() {
          licenses = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle non-200 status code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load licenses: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("License List"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : licenses.isEmpty
              ? const Center(child: Text('No licenses found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: licenses.length,
                  itemBuilder: (context, index) {
                    var license = licenses[index];
                    return _buildLicenseCard(context, license);
                  },
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
                color: Colors.grey.shade300, blurRadius: 4, spreadRadius: 1),
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
                      fontWeight: FontWeight.bold, fontSize: 16),
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

Widget _buildBottomNavBar(BuildContext context) {
  return BottomAppBar(
    color: Colors.white,
    shape: const CircularNotchedRectangle(),
    notchMargin: 8.0,
    child: SizedBox(
      height: 65, // Increased height to accommodate labels
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Icon with Label
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 28),
                onPressed: () {},
                color: const Color(0xFFB0B9E0),
              ),
              const Text(
                "Home",
                style: TextStyle(fontSize: 12, color: Color(0xFFB0B9E0)),
              ),
            ],
          ),
          // Calendar Icon with Label
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month, size: 28),
                onPressed: () {},
                color: const Color(0xFFB0B9E0),
              ),
              const Text(
                "Calendar",
                style: TextStyle(fontSize: 12, color: Color(0xFFB0B9E0)),
              ),
            ],
          ),
          const SizedBox(width: 40), // Space for the floating action button
          // License Icon with Label
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.description, size: 28),
                onPressed: () {},
                color: const Color(0xFFB0B9E0),
              ),
              const Text(
                "License",
                style: TextStyle(fontSize: 12, color: Color(0xFFB0B9E0)),
              ),
            ],
          ),
          // Account Icon with Label
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.account_circle, size: 28),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ));
                },
                color: const Color(0xFFB0B9E0),
              ),
              const Text(
                "Account",
                style: TextStyle(fontSize: 12, color: Color(0xFFB0B9E0)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
