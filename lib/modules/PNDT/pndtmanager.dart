import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:track_in/modules/PNDT/pndtlist.dart';
import 'package:track_in/send_notificatioin.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/profile.dart';

class PndtManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurvedHeader(),
            SizedBox(height: 20),
            ImageCarousel(),
            SizedBox(height: 20),
            OverviewSection(),
            SizedBox(height: 20),
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
            padding: EdgeInsets.only(top: 50, left: 20, right: 20),
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
                backgroundImage:
                    NetworkImage("https://via.placeholder.com/150"),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello Alex A P",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    Text("Have a nice day.",
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
              Stack(
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
      options:
          CarouselOptions(height: 180, autoPlay: true, enlargeCenterPage: true),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Overview",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            height: 180, // Keep height consistent with ImageCarousel
            padding: EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Licenses",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),

                // Horizontal Bar Graph
                HorizontalTotal(
                  active: 80,
                  expired: 30,
                  upcoming: 50,
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
        SizedBox(width: 10),
        Expanded(
          // Pushes text to the left
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          // Number stays at right
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
        SizedBox(height: 8),

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

        SizedBox(height: 20),

        // Indicator labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Indicator(color: Colors.blue, label: "Active", count: "$active"),
            SizedBox(height: 4),
            Indicator(color: Colors.red, label: "Expired", count: "$expired"),
            SizedBox(height: 4),
            Indicator(
                color: Colors.yellow, label: "Upcoming", count: "$upcoming"),
          ],
        ),
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
                        'label': 'Profile',
                        'route': ProfileScreen()
                      },
                      {
                        'icon': Icons.settings,
                        'label': 'Settings',
                        //'route': SettingsScreen()
                      },
                      {
                        'icon': Icons.lock,
                        'label': 'Security',
                        //'route': SecurityScreen()
                      },
                      {
                        'icon': Icons.help,
                        'label': 'Help',
                        // 'route': HelpScreen()
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
                buildLicenseCard(context, "License1", "HUH937887"),
                const SizedBox(width: 6), // Adds spacing between cards
                buildLicenseCard(context, "License2", "KNA176273"),
                const SizedBox(width: 6),
                buildLicenseCard(context, "License3", "GYB278672"),
                const SizedBox(width: 6),
              ],
            ),
          ),
          SizedBox(height: 16),
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
            builder: (context) => Pndtlist(), // Navigate to LicenseListApp
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

  Widget buildLicenseCard(
      BuildContext context, String name, String licenseNumber) {
    double cardWidth = MediaQuery.of(context).size.width *
        0.48; // Adjust width so 2 fit on screen

    return Container(
      width: cardWidth, // Set fixed width
      margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4), // Add margin for better shadow visibility
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

          // License Name (Limited to one line)
          SizedBox(
            width: cardWidth - 24, // Prevent overflow
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1, // Ensure only one line
              overflow: TextOverflow.ellipsis, // Truncate long names with "..."
            ),
          ),
          const SizedBox(height: 4),

          // License Number
          Text(
            "$licenseNumber",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
