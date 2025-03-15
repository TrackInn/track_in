import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_in/edit_profile.dart';
import 'package:track_in/login_screen.dart';
import 'package:track_in/security_screen.dart';
import 'package:track_in/help_screen.dart';
import 'package:track_in/baseurl.dart'; // Import the base URL

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<Map<String, dynamic>> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('userDetails');
    final profileImage =
        prefs.getString('profileImage'); // Fetch profile image URL

    // Construct the full URL for the profile image
    String fullProfileImageUrl;
    if (profileImage != null && profileImage.isNotEmpty) {
      // Remove '/api' from baseurl for the profile image URL
      final baseUrlWithoutApi = baseurl.replaceAll('/api', '');
      fullProfileImageUrl =
          '$baseUrlWithoutApi$profileImage'; // Combine baseurl and profileImage
    } else {
      fullProfileImageUrl =
          ''; // Fallback to an empty string if no image is available
    }

    print("Fetched Profile Image URL: $fullProfileImageUrl"); // Debug print

    if (userDetails != null) {
      final user = json.decode(userDetails);
      return {
        'username': user['username'] ?? "User",
        'role': user['role'] ?? "Role",
        'profileImage': fullProfileImageUrl, // Use the full URL
      };
    }
    return {'username': "User", 'role': "Role", 'profileImage': null};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final username = snapshot.data?['username'] ?? "User";
          final role = snapshot.data?['role'] ?? "Role";
          final profileImage = snapshot.data?['profileImage'];

          // Parse the fullProfileImageUrl into a Uri object
          final Uri? profileImageUri =
              profileImage != null && profileImage.isNotEmpty
                  ? Uri.tryParse(profileImage)
                  : null;

          return Column(
            children: [
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
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUri != null
                              ? NetworkImage(profileImageUri
                                  .toString()) // Use the parsed Uri
                              : AssetImage("assets/images/broken-image.png")
                                  as ImageProvider,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
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
                    Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      role,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                      buildProfileOption(
                        Icons.lock,
                        "Security",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecurityScreen(),
                            ),
                          );
                        },
                      ),
                      buildProfileOption(
                        Icons.help,
                        "Help",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpScreen(),
                            ),
                          );
                        },
                      ),
                      buildProfileOption(
                        Icons.logout,
                        "Logout",
                        isLogout: true,
                        onPressed: () {
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
                                    Navigator.pop(context);
                                    _logout(context);
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
          );
        },
      ),
    );
  }

  Widget buildProfileOption(
    IconData icon,
    String title, {
    bool isLogout = false,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
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
