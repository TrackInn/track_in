import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_in/app_settings.dart';
import 'package:track_in/edit_profile.dart';
import 'package:track_in/help_screen.dart';
import 'package:track_in/icon_search.dart';
import 'package:track_in/modules/PNDT_Viewer/recent_pndt.dart';
import 'package:track_in/security_screen.dart';
import 'package:track_in/send_notificatioin.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';
import 'package:track_in/viewer_notificaction_view.dart'; // Import the base URL

class PndtManager extends StatefulWidget {
  @override
  _PndtManagerState createState() => _PndtManagerState();
}

class _PndtManagerState extends State<PndtManager> {
  String username = "Loading..."; // Default value

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Fetch username from SharedPreferences
  }

  // Fetch username from SharedPreferences
  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('userDetails');
    if (userDetails != null) {
      final user = json.decode(userDetails);
      setState(() {
        username = user['username'] ??
            "User"; // Fallback to "User" if username is null
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
            CurvedHeader(username: username), // Pass the username to the header
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

class CurvedHeader extends StatelessWidget {
  final String username;

  const CurvedHeader({required this.username});

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

    if (userDetails != null) {
      final user = json.decode(userDetails);
      return {
        'username': user['username'] ?? "User",
        'profileImage': fullProfileImageUrl, // Use the full URL
      };
    }
    return {'username': "User", 'profileImage': null};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final username = snapshot.data?['username'] ?? "User";
        final profileImage = snapshot.data?['profileImage'];

        // Parse the fullProfileImageUrl into a Uri object
        final Uri? profileImageUri =
            profileImage != null && profileImage.isNotEmpty
                ? Uri.tryParse(profileImage)
                : null;

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
                    radius: 38,
                    backgroundImage: profileImageUri != null
                        ? NetworkImage(
                            profileImageUri.toString()) // Use the parsed Uri
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
                        Text("Have a nice day.",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
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
                  // Search Icon (Clickable)
                  GestureDetector(
                    onTap: () {
                      // Navigate to SearchScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                    child:
                        const Icon(Icons.search, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 15),

                  // Notification Icon (Clickable)
                  GestureDetector(
                    onTap: () {
                      // Navigate to NotificationScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewersNotifications()),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications,
                            color: Colors.white, size: 26),
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
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
    "assets/images/PNDT-banner-1.jpeg",
    "assets/images/PNDT-banner-2.webp",
    "assets/images/PNDT-banner-3.webp",
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
  Map<String, dynamic>? _pndtStats;

  @override
  void initState() {
    super.initState();
    _fetchPndtStats();
  }

  Future<void> _fetchPndtStats() async {
    final response = await http.get(Uri.parse('$baseurl/pndtoverview/'));
    if (response.statusCode == 200) {
      setState(() {
        _pndtStats = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load PNDT statistics');
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
            height: 180, // Keep height consistent with ImageCarousel
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    spreadRadius: 1),
              ],
            ),
            child: _pndtStats == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Licenses",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),

                      // Horizontal Bar Graph
                      HorizontalTotal(
                        active: _pndtStats!['active_licenses'],
                        expired: _pndtStats!['expired_licenses'],
                        upcoming: _pndtStats!['expiring_soon'],
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

  Indicator({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Horizontal Bar Graph for Total Licenses
class HorizontalTotal extends StatelessWidget {
  final int active;
  final int expired;
  final int upcoming;

  HorizontalTotal({
    required this.active,
    required this.expired,
    required this.upcoming,
  });

  @override
  Widget build(BuildContext context) {
    double total = (active + expired + upcoming).toDouble();
    double activePercentage = active.toDouble() / total;
    double expiredPercentage = expired.toDouble() / total;
    double upcomingPercentage = upcoming.toDouble() / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Bar Graph with reduced height
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth; // Get available width

            return Container(
              height: 5, // Reduced height for thinner appearance
              width: maxWidth, // Fit within available space
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Container(
                    height: 5, // Thinner bar
                    width: maxWidth * activePercentage,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(5)),
                    ),
                  ),
                  Container(
                    height: 5, // Thinner bar
                    width: maxWidth * expiredPercentage,
                    color: Colors.red,
                  ),
                  Container(
                    height: 5, // Thinner bar
                    width: maxWidth * upcomingPercentage,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(5)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Indicator labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Indicator(color: Colors.blue, label: "Active", count: "$active"),
            const SizedBox(height: 4),
            Indicator(color: Colors.red, label: "Expired", count: "$expired"),
            const SizedBox(height: 4),
            Indicator(
                color: Colors.yellow, label: "Upcoming", count: "$upcoming"),
          ],
        ),
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
  bool _showRecentlyAdded = true; // Toggle state
  String _selectedFilter = 'all'; // Filter state

  List<Map<String, dynamic>> recentlyAddedPndtItems = [];
  List<Map<String, dynamic>> recentlyViewedPndtItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentlyAddedPndt();
    _fetchRecentlyViewedPndt();
  }

  Future<void> _fetchRecentlyAddedPndt() async {
    final response = await http
        .get(Uri.parse('$baseurl/recentlyadded/?filter=$_selectedFilter'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Only use PNDT License data
        recentlyAddedPndtItems = [
          for (var pndtLicense in data['recent_pndt_licenses'])
            {
              "name": pndtLicense["product_name"],
              "application_number": pndtLicense["application_number"],
              "type": "Recently Added", // Add label
            },
        ];
      });
    } else {
      print(
          'Failed to load recently added PNDT licenses: ${response.statusCode}');
    }
  }

  Future<void> _fetchRecentlyViewedPndt() async {
    final response = await http.get(Uri.parse('$baseurl/recentlyviewed/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Only use PNDT License data
        recentlyViewedPndtItems = [
          for (var pndtLicense in data['recently_viewed_pndt_licenses'])
            {
              "name": pndtLicense["product_name"],
              "application_number": pndtLicense["application_number"],
              "type": "Recently Viewed", // Add label
            },
        ];
      });
    } else {
      print(
          'Failed to load recently viewed PNDT licenses: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine both lists
    List<Map<String, dynamic>> recentItems = [
      ...recentlyAddedPndtItems,
      ...recentlyViewedPndtItems,
    ];

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
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> items = [
                      {
                        'icon': Icons.send,
                        'label': 'Send Notification',
                        'route': SendNotificationScreen()
                      },
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
              Container(child: _buildViewAllButton(context)),
            ],
          ),

          // List of licenses
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enables horizontal scrolling
            child: Row(
              children: [
                for (var item in recentItems)
                  _buildPndtLicenseCard(context, item),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                const ToggleCardScreen(), // Navigate to ToggleCardScreen
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

  // Widget for individual PNDT license item
  Widget _buildPndtLicenseCard(
      BuildContext context, Map<String, dynamic> data) {
    double cardWidth = MediaQuery.of(context).size.width * 0.48;

    return Container(
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
          // Static License Icon
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
                  Icons.assignment, // License Icon
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),

          // Product Name (Limited to one line)
          SizedBox(
            width: cardWidth - 24, // Prevent overflow
            child: Text(
              data["name"]!, // Display product_name
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1, // Ensure only one line
              overflow: TextOverflow.ellipsis, // Truncate long names with "..."
            ),
          ),
          const SizedBox(height: 4),

          // Application Number
          Text(
            "Application No: ${data["application_number"]}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),

          // Label (Recently Added or Recently Viewed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: data["type"] == "Recently Added"
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data["type"]!, // Display label
              style: TextStyle(
                color: data["type"] == "Recently Added"
                    ? Colors.blue
                    : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
