import 'package:flutter/material.dart';
import 'package:track_in/acc_info.dart';
import 'package:track_in/add_details.dart';
import 'package:track_in/edit_personal_info.dart';

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent, // Removed blue shadow
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/profile.jpg"),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.camera_alt,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Space between profile photo and text
                  Text(
                    "License Manager",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Personal Information Section (Editable)
            buildSectionTitle(
              "Personal Information",
              isEditable: true,
              onEditPressed: () {
                // Navigate to EditPersonalInfoScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPersonalInfoScreen(),
                  ),
                );
              },
            ),
            buildInfoTile(Icons.calendar_today, "Date of Birth", "05-01-2004"),
            buildInfoTile(Icons.person, "Gender", "Male"),
            buildInfoTile(
                Icons.bloodtype, "Blood Group", "O+"), // Added Blood Group
            buildInfoTile(
                Icons.public, "Nationality", "Indian"), // Added Nationality
            SizedBox(height: 10),
            // Additional Information Section (Editable)
            buildSectionTitle(
              "Additional Information",
              isEditable: true,
              onEditPressed: () {
                // Navigate to AdditionalDetailsScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdditionalDetailsScreen(),
                  ),
                );
              },
            ),
            buildInfoTile(Icons.map, "State", "Kerala"),
            buildInfoTile(Icons.location_city, "District", "Kozhikode"),
            buildInfoTile(Icons.pin, "Pincode", "673604"),
            buildInfoTile(Icons.phone, "Phone", "7907693769"),
            buildInfoTile(Icons.description, "Bio", "A passionate developer."),
            SizedBox(height: 10),
            // Account Information Section (Editable)
            buildSectionTitle(
              "Account Information",
              isEditable: true,
              onEditPressed: () {
                // Navigate to EditAccountInformationScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAccountInformationScreen(),
                  ),
                );
              },
            ),
            buildInfoTile(Icons.person, "Username", "abintomy22cs@lissah.com"),
            buildInfoTile(Icons.email, "Email", "abintomy22cs@lissah.com"),
            buildInfoTile(Icons.lock, "Password", "********"),
            // Non-editable Roll field
            buildInfoTile(Icons.assignment_ind, "Roll",
                "Licence Manager"), // Added Roll field
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(
    String title, {
    bool isEditable = true,
    VoidCallback? onEditPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Updated section title color to black
            ),
          ),
          if (isEditable)
            ElevatedButton.icon(
              onPressed: onEditPressed,
              icon: Icon(Icons.edit, size: 18),
              label: Text("Edit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.1),
                foregroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildInfoTile(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Divider(color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
