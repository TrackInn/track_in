import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:track_in/edit_profile.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                // Back Button and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Navigate back
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
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

                  // Languages Button
                  buildProfileOption(
                    Icons.language,
                    "Languages",
                    onPressed: () {
                      // Navigate to Languages Screen
                      print("Navigate to Languages");
                    },
                  ),

                  // Share Button
                  buildProfileOption(
                    Icons.share,
                    "Share",
                    onPressed: () {
                      // Share App or Profile
                      print("Share App");
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

                  // Logout Button
                  buildProfileOption(
                    Icons.logout,
                    "Logout",
                    isLogout: true,
                    onPressed: () {
                      // Logout Logic
                      print("User Logged Out");
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
