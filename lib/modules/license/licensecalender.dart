import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart';
import 'package:track_in/modules/license/license_details.dart';

class LicenseCalendar extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<LicenseCalendar> {
  DateTime selectedDate = DateTime.now(); // Initialize with today's date
  DateTime currentMonth = DateTime.now();
  ScrollController _scrollController = ScrollController();

  // Store all license data fetched from the backend
  Map<DateTime, List<Map<String, String>>> activeLicenses = {};
  Map<DateTime, List<Map<String, String>>> expiringLicenses = {};

  @override
  void initState() {
    super.initState();
    // Set today's date as the selected date
    selectedDate = DateTime.now();
    // Preload all license data
    _preloadLicenseData();
    // Scroll to today's date in the middle of the screen when the app is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  // Function to preload all license data from the backend
  Future<void> _preloadLicenseData() async {
    final String apiUrl = '$baseurl/license_calendar/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}), // No date parameter needed
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Clear previous data
        activeLicenses.clear();
        expiringLicenses.clear();

        // Process all licenses
        if (data['licenses'] != "No licenses found.") {
          for (var license in data['licenses']) {
            DateTime expiryDate = DateTime.parse(license['expiry_date']);
            DateTime activeDate = DateTime.parse(license['date_of_approval']);

            // Add to expiring licenses map
            expiringLicenses.putIfAbsent(expiryDate, () => []).add({
              "name": license['product_name'].toString(),
              "licenseNumber": license['license_number'].toString(),
              "expiryDate": license['expiry_date'].toString(),
            });

            // Add to active licenses map
            activeLicenses.putIfAbsent(activeDate, () => []).add({
              "name": license['product_name'].toString(),
              "licenseNumber": license['license_number'].toString(),
              "activeDate": license['date_of_approval'].toString(),
            });
          }
        }

        // Update the UI
        setState(() {});
      } else {
        // Handle API errors
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network errors
      print("Error fetching data: $e");
    }
  }

  void _scrollToToday() {
    int todayIndex = DateTime.now().day - 1; // Today's index in the list
    double capsuleWidth = 54.0;
    double padding = 6.0; // Margin between capsules
    double totalWidth = capsuleWidth + 2 * padding; // Total width per capsule

    // Calculate the scroll offset to make today the 3rd date in the visible list
    double scrollOffset =
        (todayIndex - 2) * totalWidth; // Today is the 3rd date (index 2)

    // Ensure the scroll offset is within valid bounds
    if (scrollOffset < 0) scrollOffset = 0;

    _scrollController.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasActiveLicenses = activeLicenses.containsKey(selectedDate);
    bool hasExpiringLicenses = expiringLicenses.containsKey(selectedDate);
    bool hasEvents = hasActiveLicenses || hasExpiringLicenses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month and Year Selector
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: currentMonth.month,
                      items: List.generate(12, (index) => index + 1)
                          .map((int month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(
                            _getMonthName(month),
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newMonth) {
                        setState(() {
                          currentMonth = DateTime(currentMonth.year, newMonth!);
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    DropdownButton<int>(
                      value: currentMonth.year,
                      items: List.generate(
                              91,
                              (index) =>
                                  2010 + index) // Years from 2010 to 2100
                          .map((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(
                            year.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newYear) {
                        setState(() {
                          currentMonth = DateTime(newYear!, currentMonth.month);
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Horizontal Date Picker
              Container(
                height: 92,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _getDaysInMonth(currentMonth),
                  itemBuilder: (context, index) {
                    DateTime date = DateTime(
                        currentMonth.year, currentMonth.month, index + 1);
                    bool isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;
                    bool isToday = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;
                    bool isSunday = date.weekday == 7;
                    bool hasExpiringLicense =
                        expiringLicenses.containsKey(date);
                    bool hasActiveLicense = activeLicenses.containsKey(date);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: ClipRect(
                        // Ensure the red dot is not clipped
                        child: Container(
                          width: 54, // Set the width of the capsule
                          margin:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : isToday
                                    ? Colors.blue.withOpacity(
                                        0.5) // Highlight today in blue
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          clipBehavior:
                              Clip.none, // Allow overflow for the red dot
                          child: Stack(
                            clipBehavior:
                                Clip.none, // Allow overflow for the red dot
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isSunday
                                            ? (isSelected
                                                ? Colors.red[
                                                    200] // Light red for selected Sundays
                                                : Colors
                                                    .red) // Regular red for Sundays
                                            : (isSelected || isToday
                                                ? Colors.white
                                                : Colors.black),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getDayOfWeek(date.weekday),
                                      style: TextStyle(
                                        color: isSunday
                                            ? (isSelected
                                                ? Colors.red[
                                                    200] // Light red for selected Sundays
                                                : Colors
                                                    .red) // Regular red for Sundays
                                            : (isSelected || isToday
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasExpiringLicense || hasActiveLicense)
                                Positioned(
                                  top:
                                      -10, // Move the dot partially outside the capsule
                                  right:
                                      -10, // Move the dot partially outside the capsule
                                  child: Container(
                                    width: 12, // Increase the size of the dot
                                    height: 12, // Increase the size of the dot
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // Display Date and License Cards (or "No events" text)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Display (dd at the top of MMM)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          selectedDate.day.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getMonthName(selectedDate.month),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),

                  // License Cards or "No events" text
                  Expanded(
                    child: hasEvents
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasActiveLicenses)
                                ...activeLicenses[selectedDate]!
                                    .map((license) => GestureDetector(
                                          onTap: () {
                                            // Navigate to the LicenseDetailScreen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LicenseDetailScreen(
                                                        data: license),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              horizontalTitleGap: 0,
                                              leading: Container(
                                                width: 4,
                                                height: 40,
                                                color: Colors.green,
                                                margin:
                                                    EdgeInsets.only(right: 4),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    license["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'License: ${license["licenseNumber"]}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Active from ${license["activeDate"]}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              if (hasExpiringLicenses)
                                ...expiringLicenses[selectedDate]!
                                    .map((license) => GestureDetector(
                                          onTap: () {
                                            // Navigate to the LicenseDetailScreen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LicenseDetailScreen(
                                                        data: license),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              horizontalTitleGap: 0,
                                              leading: Container(
                                                width: 4,
                                                height: 40,
                                                color: Colors.red,
                                                margin:
                                                    EdgeInsets.only(right: 4),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    license["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'License: ${license["licenseNumber"]}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Expires on ${license["expiryDate"]}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            ],
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.only(top: 24.0, right: 56),
                            child: const Center(
                              child: Text(
                                'No events',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}
