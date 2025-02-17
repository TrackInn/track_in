import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LicenseDashboard(),
  ));
}

class LicenseDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: CustomBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
    "https://source.unsplash.com/400x300/?city,building",
    "https://source.unsplash.com/400x300/?tech,office",
    "https://source.unsplash.com/400x300/?business,corporate"
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
            height: 180, // Same height as ImageCarousel
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center vertically
              children: [
                // Left side: Text and Indicators
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align content to the top
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10), // Move the heading slightly upward
                        child: Text("Total Licenses",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28, // Increased font size
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Indicator(
                              color: Colors.blue, label: "Active", count: "85"),
                          SizedBox(height: 5),
                          Indicator(
                              color: Colors.red, label: "Expired", count: "25"),
                          SizedBox(height: 5),
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

  Indicator({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 5),
        Text("$label : $count",
            style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

// Circular Total Licenses Count with dynamic color
class CircularTotal extends StatelessWidget {
  final int active;
  final int expired;
  final int upcoming;

  CircularTotal(
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: activePercentage + expiredPercentage,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: activePercentage,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
        Text("$total",
            style: TextStyle(
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Section
          IconSection(), // Add the new IconSection here
          SizedBox(height: 20),

          // Filter section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("All (12)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Recent (5)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("View All",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
            ],
          ),
          SizedBox(height: 20),

          // List of licenses
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LicenseItem(name: "License1", date: "17 Aug 2020"),
              LicenseItem(name: "License2", date: "26 July 2022"),
              LicenseItem(name: "License3", date: "22 Sep 2024"),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget for individual license item
class LicenseItem extends StatelessWidget {
  final String name;
  final String date;

  LicenseItem({required this.name, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(date, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

// Icon Section
class IconSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Feedback
          Column(
            children: [
              Icon(Icons.feedback, size: 30, color: Colors.blue),
              SizedBox(height: 5),
              Text("Feedback",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
          // Send Notification
          Column(
            children: [
              Icon(Icons.send, size: 30, color: Colors.blue),
              SizedBox(height: 5),
              Text("Send", style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
          // My Account
          Column(
            children: [
              Icon(Icons.account_circle, size: 30, color: Colors.blue),
              SizedBox(height: 5),
              Text("My Account",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
          // Downloads
          Column(
            children: [
              Icon(Icons.download, size: 30, color: Colors.blue),
              SizedBox(height: 5),
              Text("Downloads",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
          // Settings
          Column(
            children: [
              Icon(Icons.settings, size: 30, color: Colors.blue),
              SizedBox(height: 5),
              Text("Settings",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Bottom Navigation Bar
class CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: Icon(Icons.home, color: Colors.blue), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.grey),
              onPressed: () {}),
          SizedBox(width: 40), // Space for FAB
          IconButton(
              icon: Icon(Icons.article, color: Colors.grey), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.person, color: Colors.grey), onPressed: () {}),
        ],
      ),
    );
  }
}
