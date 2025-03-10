import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(MaterialApp(
    home: TrackInApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Color(0xFF0A0E21), // Dark blue background
      primaryColor: Color(0xFF1D1E33), // Blue accent
      cardColor: Color(0xFF1D1E33), // Card color
    ),
  ));
}

class TrackInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(),
            DateSelector(),
            Expanded(child: LicenseTimeline()),
          ],
        ),
      ),
    );
  }
}

// 🔹 Header Section (Top Bar)
class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back_ios, color: Colors.white),
          Text("License Expiry",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins')),
          Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }
}

// 🔹 Capsule-Shaped Date Selector with Advanced Calendar Features
class DateSelector extends StatefulWidget {
  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final List<int> _dates = List.generate(31, (index) => index + 1);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Date Picker Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () => _selectDate(context),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: 'Poppins'),
              ),
              IconButton(
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                onPressed: () => _selectMonthYear(context),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Weekday and Date Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_days.length, (index) {
              bool isSelected = _selectedDate.weekday == index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(
                        Duration(days: _selectedDate.weekday - (index + 1)));
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: isSelected ? 50 : 40,
                      height: isSelected ? 50 : 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.blueAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white30, width: isSelected ? 0 : 2),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _dates[_selectedDate.day - 1].toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(_days[index],
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Poppins')),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// 🔹 License Timeline (List of Expired Licenses)
class LicenseTimeline extends StatelessWidget {
  final List<License> licenses = [
    License("Import License", "MRI Machine", "Expired", "2023-10-10",
        Colors.red, Icons.api),
    License("Test License", "CT Scanner", "Expired", "2023-10-12",
        Colors.orange, Icons.scanner),
    License("Warehouse License", "X-ray Machine", "Expiring Soon", "2023-10-15",
        Colors.yellow, Icons.medical_services),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 20),
      itemCount: licenses.length,
      itemBuilder: (context, index) {
        return LicenseCard(
            license: licenses[index], time: "${10 + index * 3} AM");
      },
    );
  }
}

// 🔹 License Card (Contains Status, Title, Expiry Date)
class LicenseCard extends StatelessWidget {
  final License license;
  final String time;

  LicenseCard({required this.license, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Time
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(time,
                style: TextStyle(
                    color: Colors.white, fontSize: 14, fontFamily: 'Poppins')),
          ),
          SizedBox(width: 20),

          // License Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: license.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(license.status,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontFamily: 'Poppins')),
                  ),
                  SizedBox(height: 10),

                  // License Title & Subtitle
                  Row(
                    children: [
                      Icon(license.icon, color: Colors.white70, size: 20),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(license.title,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Poppins')),
                          Text(license.subtitle,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontFamily: 'Poppins')),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Expiry Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.white54, size: 16),
                      SizedBox(width: 5),
                      Text("Expiry: ${license.expiryDate}",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 License Model
class License {
  final String title, subtitle, status, expiryDate;
  final Color color;
  final IconData icon;

  License(this.title, this.subtitle, this.status, this.expiryDate, this.color,
      this.icon);
}
