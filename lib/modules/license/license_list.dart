import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart';
import 'dart:convert';

import 'package:track_in/modules/license/license_details.dart';

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
    final response = await http.get(Uri.parse('$baseurl/list/'));
    if (response.statusCode == 200) {
      setState(() {
        licenses = json.decode(response.body);
        print(licenses);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("License List"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: licenses.length,
              itemBuilder: (context, index) {
                var license = licenses[index];
                return _buildLicenseCard(context, license);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
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
                Text(data['product_name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("License No: ${data['license_number'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBottomNavBar() {
  return BottomAppBar(
    shape: const CircularNotchedRectangle(),
    notchMargin: 8.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(icon: const Icon(Icons.home, size: 32), onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.calendar_today, size: 32), onPressed: () {}),
        const SizedBox(width: 40),
        IconButton(
            icon: const Icon(Icons.description, size: 32), onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.account_circle, size: 32), onPressed: () {}),
      ],
    ),
  );
}
