import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For clearing session data
import 'package:track_in/edit_profile.dart';
import 'package:track_in/login_screen.dart'; // Import your LoginScreen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    // Clear user session data (e.g., using SharedPreferences)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data

    // Navigate to the LoginScreen and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false, // Remove all routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: [
                // App Bar with Title (No Help Button)
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align text to the left
                  children: [
                    Text(
                      "My Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile Picture with Edit Button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    InkWell(
                      onTap: () {
                        // Add logic to edit profile picture
                        print("Edit Profile Picture");
                      },
                      borderRadius: BorderRadius.circular(15),
                      splashColor: Colors.transparent, // No splash effect
                      highlightColor: Colors.transparent, // No highlight effect
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit,
                            size: 15, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // User Name and Role
                Text(
                  "Alex A P",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "License Manager",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Profile Options Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Edit Profile Button
                  buildProfileOption(
                    Icons.person,
                    "Edit Profile",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ));
                    },
                  ),

                  // Security Button
                  buildProfileOption(
                    Icons.lock,
                    "Security",
                    onPressed: () {
                      // Navigate to Security Screen
                      print("Navigate to Security");
                    },
                  ),

                  // About Button
                  buildProfileOption(
                    Icons.info,
                    "About",
                    onPressed: () {
                      // Navigate to About Screen
                      print("Navigate to About");
                    },
                  ),
                  // Help Button
                  buildProfileOption(
                    Icons.help,
                    "Help",
                    onPressed: () {
                      // Navigate to Help Screen
                      print("Navigate to Help");
                    },
                  ),

                  // Logout Button
                  buildProfileOption(
                    Icons.logout,
                    "Logout",
                    isLogout: true,
                    onPressed: () {
                      // Show a confirmation dialog before logging out
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                                _logout(context); // Perform logout
                              },
                              child: Text('Logout',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Profile Option Widget
  Widget buildProfileOption(
    IconData icon,
    String title, {
    bool isLogout = false,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.transparent, // No splash effect
      highlightColor: Colors.transparent, // No highlight effect
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : Colors.blue),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black87,
              ),
            ),
            const Spacer(),
            if (!isLogout)
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
