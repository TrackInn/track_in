import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';
import 'package:track_in/modules/tender/tenderdetails.dart'; // Import the TenderDetailScreen

class TenderCalendar extends StatefulWidget {
  @override
  _TenderCalendarState createState() => _TenderCalendarState();
}

class _TenderCalendarState extends State<TenderCalendar> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  ScrollController _scrollController = ScrollController();

  // Store all tender data fetched from the backend
  Map<DateTime, List<Map<String, dynamic>>> emdPaymentTenders = {};
  Map<DateTime, List<Map<String, dynamic>>> emdRefundTenders = {};

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _preloadTenderData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  // Function to preload all tender data from the backend
  Future<void> _preloadTenderData() async {
    final String apiUrl = '$baseurl/tender_calendar/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> tenders = responseData['tenders'];

        // Clear previous data
        emdPaymentTenders.clear();
        emdRefundTenders.clear();

        // Process all tenders
        for (var tender in tenders) {
          // Handle EMD payment date
          if (tender['emd_payment_date'] != null) {
            DateTime paymentDate = DateTime.parse(tender['emd_payment_date']);
            emdPaymentTenders.putIfAbsent(paymentDate, () => []).add(tender);
          }

          // Handle EMD refund date
          if (tender['emd_refund_date'] != null) {
            DateTime refundDate = DateTime.parse(tender['emd_refund_date']);
            emdRefundTenders.putIfAbsent(refundDate, () => []).add(tender);
          }
        }

        // Update the UI
        setState(() {});
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _scrollToToday() {
    int todayIndex = DateTime.now().day - 1;
    double capsuleWidth = 54.0;
    double padding = 6.0;
    double totalWidth = capsuleWidth + 2 * padding;

    double scrollOffset = (todayIndex - 2) * totalWidth;
    if (scrollOffset < 0) scrollOffset = 0;

    _scrollController.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasEmdPaymentTenders = emdPaymentTenders.containsKey(selectedDate);
    bool hasEmdRefundTenders = emdRefundTenders.containsKey(selectedDate);
    bool hasEvents = hasEmdPaymentTenders || hasEmdRefundTenders;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Text(
          "Tender Calendar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                      items: List.generate(91, (index) => 2010 + index)
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
                    bool hasEmdPayment = emdPaymentTenders.containsKey(date);
                    bool hasEmdRefund = emdRefundTenders.containsKey(date);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: ClipRect(
                        child: Container(
                          width: 54,
                          margin:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : isToday
                                    ? Colors.blue.withOpacity(0.5)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
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
                                                ? Colors.red[200]
                                                : Colors.red)
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
                                                ? Colors.red[200]
                                                : Colors.red)
                                            : (isSelected || isToday
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasEmdPayment || hasEmdRefund)
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
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

              // Display Date and Tender Cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Display
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
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

                  // Tender Cards or "No tenders" text
                  Expanded(
                    child: hasEvents
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasEmdPaymentTenders)
                                ...emdPaymentTenders[selectedDate]!
                                    .map((tender) => _buildTenderCard(
                                          context,
                                          tender,
                                          Colors.blue,
                                          'Applied on : ${tender['emd_payment_date']}',
                                        ))
                                    .toList(),
                              if (hasEmdRefundTenders)
                                ...emdRefundTenders[selectedDate]!
                                    .map((tender) => _buildTenderCard(
                                          context,
                                          tender,
                                          Colors.green,
                                          'EMD Refunded on : ${tender['emd_refund_date']}',
                                        ))
                                    .toList(),
                            ],
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.only(top: 24.0, right: 56),
                            child: const Center(
                              child: Text(
                                'No tenders',
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

  Widget _buildTenderCard(BuildContext context, Map<String, dynamic> tender,
      Color indicatorColor, String dateText) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TenderDetails(data: tender),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          horizontalTitleGap: 0,
          leading: Container(
            width: 4,
            height: 40,
            color: indicatorColor,
            margin: EdgeInsets.only(right: 4),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tender['tender_name'] ?? 'No Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Tender ID: ${tender['tender_id']}',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 12,
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
