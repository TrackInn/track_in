import 'package:flutter/material.dart';

class PNDTLicenseCalendar extends StatefulWidget {
  @override
  _PNDTLicenseCalendarState createState() => _PNDTLicenseCalendarState();
}

class _PNDTLicenseCalendarState extends State<PNDTLicenseCalendar> {
  DateTime selectedDate = DateTime.now(); // Initialize with today's date
  DateTime currentMonth = DateTime.now();
  ScrollController _scrollController = ScrollController();

  // Sample PNDT License data (replace with your actual data)
  final Map<DateTime, List<Map<String, dynamic>>> pndtLicensesByDate = {
    DateTime(2025, 03, 16): [
      {
        "license_number": "L12345",
        "product_name": "Ultrasound Machine",
        "submission_date": "2023-10-16",
        "expiry_date": "2025-10-16",
        "state": "STATE_1",
        "class_of_device": "ultrasonic",
      },
      {
        "license_number": "L67890",
        "product_name": "X-Ray Machine",
        "submission_date": "2023-10-16",
        "expiry_date": "2025-10-16",
        "state": "STATE_2",
        "class_of_device": "class2",
      },
    ],
    DateTime(2025, 03, 20): [
      {
        "license_number": "L54321",
        "product_name": "MRI Machine",
        "submission_date": "2023-10-20",
        "expiry_date": "2025-10-20",
        "state": "STATE_3",
        "class_of_device": "class3",
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    // Set today's date as the selected date
    selectedDate = DateTime.now();
    // Scroll to today's date in the middle of the screen when the app is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
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
    bool hasPNDTLicenses = pndtLicensesByDate.containsKey(selectedDate);

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
                    bool hasPNDTLicense = pndtLicensesByDate.containsKey(date);

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
                              if (hasPNDTLicense)
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
              // Display "No PNDT Licenses" if there are no licenses
              if (!hasPNDTLicenses)
                Center(
                  child: Text(
                    'No PNDT Licenses',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // PNDT Licenses Applied On Selected Date
              if (hasPNDTLicenses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PNDT Licenses Applied On ${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...pndtLicensesByDate[selectedDate]!
                          .map((license) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 4,
                                    height: 40,
                                    color: Colors
                                        .green, // Green for active licenses
                                  ),
                                  title: Text(license["product_name"]!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'License Number: ${license["license_number"]}\nState: ${license["state"]}\nExpiry Date: ${license["expiry_date"]}'),
                                ),
                              ))
                          .toList(),
                    ],
                  ),
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
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}
