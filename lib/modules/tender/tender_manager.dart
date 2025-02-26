import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/profile.dart';
import 'dart:async';

import 'package:track_in/send_notificatioin.dart';

class TenderManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/profile.jpg'),
                          radius: 25,
                        ),
                        Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Stack(
                              children: [
                                Icon(Icons.notifications, color: Colors.white),
                                Positioned(
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Hello Gabriella',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Have a nice day.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ImageCarousel(),
              Padding(
                padding: EdgeInsets.only(left: 16, top: 32),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Overview',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildOverviewCard('Completed', '68 new tenders accepted',
                        Colors.green, Icons.check),
                    _buildOverviewCard('Rejected', '28 new tenders rejected',
                        Colors.red, Icons.close),
                    _buildOverviewCard('EMD Pending', '12 new tenders pending',
                        Colors.orange, Icons.access_time),
                    _buildOverviewCard('Requested', '23 new tenders requested',
                        Colors.blue, Icons.link),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 0, left: 16, right: 16, bottom: 28),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    builder: (context) =>
                                        items[index]['route']),
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
                                        color:
                                            Colors.blueAccent.withOpacity(0.1),
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
                                  style:
                                      const TextStyle(fontSize: 12, height: 1),
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
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EMDContainer(),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String subtitle, Color color, IconData icon) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                Spacer(),
                Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 5),
            Text(subtitle, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Icon(icon, color: Colors.blue, size: 30),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class EMDContainer extends StatefulWidget {
  const EMDContainer({super.key});

  @override
  _EMDContainerState createState() => _EMDContainerState();
}

class _EMDContainerState extends State<EMDContainer> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 4) {
        _currentPage += 1;
      } else {
        _currentPage = 0;
        _pageController.jumpToPage(0);
      }
      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "TOTAL PENDING EMD",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Circular Chart
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                        startDegreeOffset: 270,
                        sections: [
                          PieChartSectionData(
                            color: Colors.purple,
                            value: 75, // 75% filled
                            radius: 10,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: Colors.grey[300],
                            value: 25, // Remaining 25%
                            radius: 10,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "\$57,500.00",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Hospital Cards Carousel (Vertical)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 85,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final hospitalData = [
                      HospitalCard(
                        icon: Icons.home_work,
                        title: "HOSPITAL 1",
                        date: "17 Aug 2020",
                        amount: "\$13,528.31",
                        bgColor: Colors.purple[100]!,
                      ),
                      HospitalCard(
                        icon: Icons.business,
                        title: "HOSPITAL 2",
                        date: "26 July 2022",
                        amount: "\$28,342.93",
                        bgColor: Colors.orange[100]!,
                      ),
                      HospitalCard(
                        icon: Icons.local_hospital,
                        title: "HOSPITAL 3",
                        date: "12 Dec 2021",
                        amount: "\$19,745.50",
                        bgColor: Colors.blue[100]!,
                      ),
                      HospitalCard(
                        icon: Icons.health_and_safety,
                        title: "HOSPITAL 4",
                        date: "5 May 2019",
                        amount: "\$22,678.90",
                        bgColor: Colors.green[100]!,
                      ),
                      HospitalCard(
                        icon: Icons.local_pharmacy,
                        title: "HOSPITAL 5",
                        date: "30 Jan 2023",
                        amount: "\$15,934.72",
                        bgColor: Colors.red[100]!,
                      ),
                    ];
                    return SizedBox(
                      height: 120,
                      child: hospitalData[index],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final Color bgColor;

  const HospitalCard({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.only(top: 0, bottom: 0, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black54),
          ),
          SizedBox(width: 16),
          // Hospital Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Text(date,
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class LicenseListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('License List')),
      body: Center(child: Text('License List Page')),
    );
  }
}

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
