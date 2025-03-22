import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:track_in/app_settings.dart';
import 'package:track_in/edit_profile.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/help_screen.dart';
import 'package:track_in/modules/internal_license_viewer/internal_viewer_license_list.dart';
import 'package:track_in/search_bar_viewer.dart';
import 'package:track_in/security_screen.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart';
import 'package:track_in/viewer_notificaction_view.dart'; // Import the base URL

class InternalViewerDashboard extends StatefulWidget {
  @override
  _InternalViewerDashboardState createState() =>
      _InternalViewerDashboardState();
}

class _InternalViewerDashboardState extends State<InternalViewerDashboard> {
  String username = "Loading..."; // Default value
  String profileImage = ""; // Default value

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Fetch username and profile image from SharedPreferences
  }

  // Fetch username and profile image from SharedPreferences
  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('userDetails');
    final profileImagePref = prefs.getString('profileImage');

    if (userDetails != null) {
      final user = json.decode(userDetails);
      setState(() {
        username = user['username'] ??
            "User"; // Fallback to "User" if username is null
      });
    }

    if (profileImagePref != null && profileImagePref.isNotEmpty) {
      // Remove '/api' from baseurl for the profile image URL
      final baseUrlWithoutApi = baseurl.replaceAll('/api', '');
      setState(() {
        profileImage =
            '$baseUrlWithoutApi$profileImagePref'; // Combine baseurl and profileImage
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurvedHeader(
                username: username,
                profileImage:
                    profileImage), // Pass the username and profile image to the header
            const SizedBox(height: 20),
            ImageCarousel(),
            const SizedBox(height: 20),
            OverviewSection(),
            const SizedBox(height: 20),
            ActivitySection(), // Add the new ActivitySection here
          ],
        ),
      ),
    );
  }
}

// Custom Curved Header with Profile Info
class CurvedHeader extends StatelessWidget {
  final String username;
  final String profileImage;

  const CurvedHeader({required this.username, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 260,
            color: Colors.blue,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          ),
        ),
        Positioned(
          top: 60,
          left: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : AssetImage("assets/images/broken-image.png")
                        as ImageProvider,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello $username",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const Text("Have a nice day.",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 60,
          right: 20,
          child: Row(
            children: [
              // Search Icon with Navigation to SearchScreen
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchScreenViewer(), // Navigate to SearchScreen
                    ),
                  );
                },
                child: Icon(Icons.search, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ViewersNotifications()),
                  );
                },
                child: Stack(
                  children: [
                    Icon(Icons.notifications, color: Colors.white, size: 26),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Clipper for Exact Curve
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height - 50);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 100, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Image Carousel
class ImageCarousel extends StatelessWidget {
  final List<String> images = [
    "assets/images/CDSCO-banner-1.jpg",
    "assets/images/CDSCO-banner-2.webp",
    "assets/images/CDSCO-banner-3.webp",
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: images.map((imgPath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child:
              Image.asset(imgPath, width: double.infinity, fit: BoxFit.cover),
        );
      }).toList(),
    );
  }
}

// Overview Section with Circular Stats
class OverviewSection extends StatefulWidget {
  @override
  _OverviewSectionState createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection> {
  Map<String, dynamic>? _licenseStats;

  @override
  void initState() {
    super.initState();
    _fetchLicenseStats();
  }

  Future<void> _fetchLicenseStats() async {
    final response = await http.get(Uri.parse('$baseurl/licenseoverview/'));
    if (response.statusCode == 200) {
      setState(() {
        _licenseStats = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load license statistics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            height: 180, // Same height as ImageCarousel
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: _licenseStats == null
                ? Center(child: CircularProgressIndicator())
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side: Text and Indicators
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: const Text("Total Licenses",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Indicator(
                                    color: Colors.blue,
                                    label: "Active",
                                    count: _licenseStats!['active_licenses']
                                        .toString()),
                                const SizedBox(height: 5),
                                Indicator(
                                    color: Colors.red,
                                    label: "Expired",
                                    count: _licenseStats!['expired_licenses']
                                        .toString()),
                                const SizedBox(height: 5),
                                Indicator(
                                    color: Colors.yellow,
                                    label: "Expiring Soon",
                                    count: _licenseStats!['expiring_soon']
                                        .toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Right side: Circular Progress Bar
                      CircularTotal(
                        active: _licenseStats!['active_licenses'],
                        expired: _licenseStats!['expired_licenses'],
                        expiringSoon: _licenseStats!['expiring_soon'],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Circular Stats Indicator
class Indicator extends StatelessWidget {
  final Color color;
  final String label;
  final String count;

  const Indicator(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text("$label : $count",
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

// Circular Total Licenses Count with dynamic color
class CircularTotal extends StatelessWidget {
  final int active;
  final int expired;
  final int expiringSoon;

  const CircularTotal(
      {required this.active,
      required this.expired,
      required this.expiringSoon});

  @override
  Widget build(BuildContext context) {
    double total =
        active.toDouble() + expired.toDouble() + expiringSoon.toDouble();
    double activePercentage = active / total;
    double expiredPercentage = expired / total;
    double expiringSoonPercentage = expiringSoon / total;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1.0, // Full circle
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: activePercentage + expiredPercentage,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: activePercentage,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
        Text("$total",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Activity Section
class ActivitySection extends StatefulWidget {
  @override
  _ActivitySectionState createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  List<Map<String, dynamic>> recentlyAddedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentlyAdded();
  }

  Future<void> _fetchRecentlyAdded() async {
    final response = await http.get(Uri.parse('$baseurl/recentlyadded/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Limit to 2 items
        recentlyAddedItems = [
          for (var i = 0; i < 2 && i < data['recent_licenses'].length; i++)
            {
              "name": data['recent_licenses'][i]["product_name"],
              "number": data['recent_licenses'][i]["application_number"],
              "type": "Recently Added", // Add label
            },
        ];
      });
    } else {
      throw Exception('Failed to load recently added licenses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Replaced IconSection with the new Container
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    spreadRadius: 1),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: 6, // Ensure 6 items in total
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> items = [
                      {
                        'icon': Icons.feedback,
                        'label': 'Feedback',
                        'route': FeedbackForm()
                      },
                      {
                        'icon': Icons.person,
                        'label': 'Edit Profile',
                        'route': EditProfileScreen()
                      },
                      {
                        'icon': Icons.settings,
                        'label': 'Settings',
                        'route': SettingsScreen()
                      },
                      {
                        'icon': Icons.lock,
                        'label': 'Security',
                        'route': SecurityScreen()
                      },
                      {
                        'icon': Icons.help,
                        'label': 'Help',
                        'route': HelpScreen()
                      },
                    ];

                    // If the index is out of range, return an empty container (vacant item)
                    if (index >= items.length) {
                      return Container(); // Empty placeholder to maintain grid structure
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => items[index]['route']),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                )
                              ],
                            ),
                            child: Icon(items[index]['icon'],
                                size: 26, color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            items[index]['label'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, height: 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter section with attractive capsule buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildViewAllButton(context),
            ],
          ),
          const SizedBox(height: 20),

          // List of licenses
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in recentlyAddedItems)
                _buildLicenseCard(context, item["name"], item["number"],
                    item["type"]), // Pass the label
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the "View All" button
  Widget _buildViewAllButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InternalViewerLicenseList(), // Navigate to LicenseListApp
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              "View All",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // Widget for individual license item
  Widget _buildLicenseCard(
      BuildContext context, String name, String number, String type) {
    return GestureDetector(
      onTap: () {
        // Handle onTap if needed
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
                color: type == "Recently Added" ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "License No: $number",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: type == "Recently Added"
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: type == "Recently Added"
                            ? Colors.blue
                            : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
