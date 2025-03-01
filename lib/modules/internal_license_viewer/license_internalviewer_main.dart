import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/modules/internal_license_viewer/license_list.dart';
import 'package:track_in/notification_view.dart';
import 'package:track_in/profile.dart';

class LicenseDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurvedHeader(),
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
              const CircleAvatar(
                radius: 35,
                backgroundImage:
                    NetworkImage("https://via.placeholder.com/150"),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Hello Alex A P",
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
              Icon(Icons.search, color: Colors.white, size: 26),
              SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()),
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
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt9x_al7IyTWjz5iplUU9voQWcQHkWJQCx1g&s",
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: images.map((imgUrl) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child:
              Image.network(imgUrl, width: double.infinity, fit: BoxFit.cover),
        );
      }).toList(),
    );
  }
}

// Overview Section with Circular Stats
class OverviewSection extends StatelessWidget {
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
            child: Row(
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
                              color: Colors.blue, label: "Active", count: "85"),
                          const SizedBox(height: 5),
                          Indicator(
                              color: Colors.red, label: "Expired", count: "25"),
                          const SizedBox(height: 5),
                          Indicator(
                              color: Colors.yellow,
                              label: "Upcoming",
                              count: "27"),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side: Circular Progress Bar
                CircularTotal(
                  active: 85,
                  expired: 25,
                  upcoming: 27,
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
  final int upcoming;

  const CircularTotal(
      {required this.active, required this.expired, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    double total = active.toDouble() + expired.toDouble() + upcoming.toDouble();
    double activePercentage = active / total;
    double expiredPercentage = expired / total;
    double upcomingPercentage = upcoming / total;

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
class ActivitySection extends StatelessWidget {
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
                        'label': 'Profile',
                        'route': ProfileScreen()
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
              _buildLicenseCard(context, "License1", "17 Aug 2020"),
              _buildLicenseCard(context, "License2", "26 July 2022"),
              _buildLicenseCard(context, "License3", "22 Sep 2024"),
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
                LicenseListApp(), // Navigate to LicenseListApp
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
  Widget _buildLicenseCard(BuildContext context, String name, String date) {
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
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Expiry Date: $date",
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

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text('Settings Screen')),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security')),
      body: Center(child: Text('Security Screen')),
    );
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: Center(child: Text('Help Screen')),
    );
  }
}
