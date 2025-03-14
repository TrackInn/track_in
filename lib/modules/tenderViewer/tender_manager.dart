import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:track_in/app_settings.dart';
import 'package:track_in/baseurl.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/help_screen.dart';
import 'package:track_in/icon_search.dart';
import 'package:track_in/modules/tenderViewer/appliedtenderslist.dart';
import 'package:track_in/modules/tenderViewer/pendingEMDlist.dart';
import 'package:track_in/modules/tenderViewer/tenderawardedlist.dart';
import 'package:track_in/modules/tenderViewer/tenderlost.dart';
import 'package:track_in/notification_view.dart';
import 'package:track_in/profile.dart';
import 'package:track_in/security_screen.dart';
import 'dart:async';
import 'package:track_in/send_notificatioin.dart';
import 'tender_service.dart'; // Import the service
import 'package:http/http.dart' as http;
import 'dart:convert';

class TenderManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _tenderCountsFuture;
  final TenderService _tenderService = TenderService();

  @override
  void initState() {
    super.initState();
    _tenderCountsFuture = _tenderService.getTenderCounts();
  }

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
              CurvedHeader(),
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _tenderCountsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Center(child: Text('No data available'));
                    } else {
                      final counts = snapshot.data!;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AppliedTenderList()),
                              );
                            },
                            child: _buildOverviewCard(
                              'Applied Tenders',
                              'Count: ${counts['applied']} ',
                              Colors.blue,
                              Icons.link,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AwardedTenderListView()),
                              );
                            },
                            child: _buildOverviewCard(
                              'Awarded Tenders',
                              'Count: ${counts['completed_won']}',
                              Colors.green,
                              Icons.check,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotAwardedTenderList()),
                              );
                            },
                            child: _buildOverviewCard(
                              'Tenders Not Awarded',
                              'Count: ${counts['rejected']}',
                              Colors.red,
                              Icons.close,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Pendingemdlist()),
                              );
                            },
                            child: _buildOverviewCard(
                              'Pending EMDs',
                              'Count: ${counts['emd_pending']} ',
                              Colors.orange,
                              Icons.access_time,
                            ),
                          ),
                        ],
                      );
                    }
                  },
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
            Spacer(), // This will push the subtitle to the bottom
            Text(subtitle,
                style: TextStyle(color: Colors.black45, fontSize: 16)),
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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
                child: Icon(Icons.search, color: Colors.white, size: 26),
              ),
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

class EMDContainer extends StatefulWidget {
  const EMDContainer({super.key});

  @override
  _EMDContainerState createState() => _EMDContainerState();
}

class _EMDContainerState extends State<EMDContainer> {
  late PageController _pageController;
  int _currentPage = 0;
  List<Map<String, dynamic>> _top5Tenders = [];
  double _totalPendingEMD = 0.0;
  double _totalCompletedEMD = 0.0; // Total EMD amount for completed tenders
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _fetchTop5PendingEMD();
    _startAutoScroll();
  }

  Future<void> _fetchTop5PendingEMD() async {
    try {
      final response = await http.get(Uri.parse('$baseurl/top5_pendingemd/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _top5Tenders = List<Map<String, dynamic>>.from(data['top_5_tenders']);
          _totalPendingEMD = data['total_emd_refund_pending'];
          _totalCompletedEMD =
              data['total_emd_completed']; // Total EMD for completed tenders
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _top5Tenders.length - 1) {
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

  // Helper function to format amount
  String formatAmount(double amount) {
    if (amount >= 10000000) {
      // Convert to Crores
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      // Convert to Lakhs
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      // Convert to Thousands
      return '₹${(amount / 1000).toStringAsFixed(2)} K';
    } else {
      // Default to Rupees
      return '₹${amount.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage of pending EMD relative to total completed EMD
    double pendingPercentage = (_totalPendingEMD / _totalCompletedEMD) * 100;
    double remainingPercentage = 100 - pendingPercentage;

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
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
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
                              color: Colors
                                  .purple, // Highlighted part (pending EMD)
                              value: pendingPercentage,
                              radius: 10,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              color: Colors.grey[
                                  300], // Unhighlighted part (remaining EMD)
                              value: remainingPercentage,
                              radius: 10,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      formatAmount(_totalPendingEMD), // Formatted amount
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 30),

            // Hospital Cards Carousel (Vertical)
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 85,
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    itemCount: _top5Tenders.length,
                    itemBuilder: (context, index) {
                      final tender = _top5Tenders[index];
                      return HospitalCard(
                        icon: Icons.home_work,
                        title: tender['tender_title'],
                        date: tender['EMD_payment_date'],
                        amount: formatAmount(double.parse(
                            tender['EMD_amount'])), // Formatted amount
                        bgColor: Colors.purple[100]!,
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
