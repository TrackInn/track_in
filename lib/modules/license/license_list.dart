import 'package:flutter/material.dart';

void main() {
  runApp(License_list());
}

class License_list extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LicenseListScreen(),
    );
  }
}

class LicenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterSortButtons(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildLicenseCard(
                    context, "License Name $index", "Active from: 29 Sep 2024");
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back, color: Colors.white, size: 24),
          Text("License List",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          CircleAvatar(
            backgroundImage: AssetImage('assets/profile.jpg'),
            radius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Filter By Button with Dropdown
          PopupMenuButton<String>(
            onSelected: (value) {
              print("Selected filter: $value"); // Implement filtering logic
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'a_to_z', child: Text("Alphabetical (A to Z)")),
              const PopupMenuItem(
                  value: 'z_to_a', child: Text("Alphabetical (Z to A)")),
              const PopupMenuItem(
                  value: 'newest_first', child: Text("Newest First")),
              const PopupMenuItem(
                  value: 'oldest_first', child: Text("Oldest First")),
            ],
            offset: const Offset(0, 40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.white,
            elevation: 3,
            child: _buildButton(Icons.filter_list, "Filter by"),
          ),
        ],
      ),
    );
  }

// Helper method to create a consistent button UI
  Widget _buildButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildLicenseCard(
      BuildContext context, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LicenseDetailScreen(title: title, subtitle: subtitle),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
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
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey)),
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
    shape: CircularNotchedRectangle(),
    notchMargin: 8.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(icon: Icon(Icons.home, size: 32), onPressed: () {}),
        IconButton(
            icon: Icon(Icons.calendar_today, size: 32), onPressed: () {}),
        SizedBox(width: 40),
        IconButton(icon: Icon(Icons.description, size: 32), onPressed: () {}),
        IconButton(
            icon: Icon(Icons.account_circle, size: 32), onPressed: () {}),
      ],
    ),
  );
}

class LicenseDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  LicenseDetailScreen({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("License Details"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(subtitle, style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow("Type of Application", "Manufacture License"),
                  _buildDetailRow("Application No.", "XXXXXXXXXX89"),
                  _buildDetailRow("License No.", "XXXXXX6754"),
                  _buildDetailRow("Date of submission", "25/07/2015"),
                  _buildDetailRow("Date of Approval", "17/08/2020"),
                  _buildDetailRow("Expiry Date", "17/08/2025"),
                  _buildDetailRow("Product Type", "Ultrasonic Device"),
                  _buildDetailRow("Product Name", "Ultrasonic Device"),
                  _buildDetailRow("Model Number", "XYZ-1234"),
                  _buildDetailRow(
                      "Intended use", "Pregnancy related scannning"),
                  _buildDetailRow("Class of device", "B level"),
                  _buildDetailRow("Software", "Not Used"),
                  _buildDetailRow("Legal Manufacturer", "Company name"),
                  _buildDetailRow(
                      "Authorize Indian agent address", "Address of agent"),
                  _buildDetailRow("Accesosories",
                      "Text field with limit of max 300 charecters"),
                  _buildDetailRow("Shell Life", "3 years"),
                  _buildDetailRow("Pack Size", "30 pcs"),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text("View Attachment"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: 16), // Add right padding
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
