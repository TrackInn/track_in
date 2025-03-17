import 'package:flutter/material.dart';

class Tendercalender extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<Tendercalender> {
  DateTime selectedDate = DateTime.now(); // Initialize with today's date
  DateTime currentMonth = DateTime.now();
  ScrollController _scrollController = ScrollController();

  // Sample tender data (replace with your actual data)
  final Map<DateTime, List<Map<String, dynamic>>> tendersByDate = {
    DateTime(2025, 03, 16): [
      {
        "tender_id": "T12345",
        "tender_title": "Construction of Bridge",
        "emd_payment_date": "2023-10-16",
        "tender_status": "applied",
        "bid_outcome": "not_declared",
      },
      {
        "tender_id": "T67890",
        "tender_title": "Road Maintenance",
        "emd_payment_date": "2023-10-16",
        "tender_status": "applied",
        "bid_outcome": "not_declared",
      },
    ],
    DateTime(2025, 03, 20): [
      {
        "tender_id": "T54321",
        "tender_title": "School Renovation",
        "emd_payment_date": "2023-10-20",
        "tender_status": "applied",
        "bid_outcome": "not_declared",
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
    bool hasTenders = tendersByDate.containsKey(selectedDate);

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
                    bool hasTender = tendersByDate.containsKey(date);

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
                              if (hasTender)
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
              // Display "No tenders" if there are no tenders
              if (!hasTenders)
                Center(
                  child: Text(
                    'No tenders',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // Tenders Applied On Selected Date
              if (hasTenders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tenders Applied On ${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...tendersByDate[selectedDate]!
                          .map((tender) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 4,
                                    height: 40,
                                    color: Colors
                                        .green, // Green for applied tenders
                                  ),
                                  title: Text(tender["tender_title"]!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Tender ID: ${tender["tender_id"]}\nEMD Paid on ${tender["emd_payment_date"]}'),
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
