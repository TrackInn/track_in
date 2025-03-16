import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:track_in/baseurl.dart';
import 'package:track_in/main.dart';
import 'package:track_in/modules/tender/tenderdetails.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class TenderScreen extends StatefulWidget {
  @override
  _TenderScreenState createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
  List<dynamic> tenderListData = [];
  List<dynamic> filteredTenderListData = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  int totalTenders = 0; // Variable to store the total number of tenders

  @override
  void initState() {
    super.initState();
    fetchTenders(); // Fetch tenders and total count in one call
  }

  Future<void> fetchTenders() async {
    final response = await http.get(Uri.parse('$baseurl/tenderlist/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        tenderListData = data['tenders']; // Get the list of tenders
        totalTenders = data['total_tender_count']; // Get the total tender count
        filteredTenderListData =
            List.from(tenderListData); // Initialize filtered list
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load tenders');
    }
  }

  void filterTenders(String query) {
    setState(() {
      filteredTenderListData = tenderListData
          .where((tender) =>
              tender['tender_title']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              tender['tender_id'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void applyFilter() {
    // Implement your filter logic here
    // For example, you can filter by status, date, etc.
    Fluttertoast.showToast(
      msg: "Filter applied!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  Future<void> downloadExcelReport() async {
    if (await Permission.storage.request().isGranted) {
      try {
        // Show "Download started" notification
        await _showNotification(
          title: 'Download Started',
          body: 'Downloading TENDER_REPORT.xlsx...',
        );

        final response =
            await http.get(Uri.parse('$baseurl/download_license_excel/'));

        if (response.statusCode == 200) {
          // Get public Download directory for Android 10 and below
          Directory? directory;
          if (Platform.isAndroid) {
            if (await Permission.manageExternalStorage.request().isGranted) {
              directory = Directory('/storage/emulated/0/Download');
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          if (directory == null) {
            throw Exception("Unable to access storage");
          }

          // Generate a unique file name by appending a timestamp
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String filePath = '${directory.path}/TENDER_REPORT_$timestamp.xlsx';
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // Show "Download complete" notification
          await _showNotification(
            title: 'Download Complete',
            body: 'File saved to: $filePath',
          );

          Fluttertoast.showToast(
            msg: "Download complete: $filePath",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          throw Exception(
              "Failed to download file. Status: ${response.statusCode}");
        }
      } catch (e) {
        print("Download error: $e");

        // Show "Download failed" notification
        await _showNotification(
          title: 'Download Failed',
          body: 'Error: $e',
        );

        Fluttertoast.showToast(
          msg: "Download failed: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Storage permission required!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      await openAppSettings();
    }
  }

// Helper function to show notifications
  Future<void> _showNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel', // Channel ID
      'Download Notifications', // Channel name
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navbar with search bar and filter button
            Container(
              height: 60,
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 8),
              color: Colors.blue,
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        hintStyle:
                            TextStyle(fontSize: 14, color: Colors.black45),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        filterTenders(
                            query); // Filter tenders based on search query
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  // Filter Button
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onPressed: applyFilter,
                  ),
                ],
              ),
            ),
            // Balance Section (Centered)
            Center(
              child: Column(
                children: [
                  Text(
                    '$totalTenders', // Display the total number of tenders
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Total Tenders',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  // Add Money Button (Centered)
                  ElevatedButton(
                    onPressed:
                        downloadExcelReport, // Call the download function
                    child: Text('Download report to Excel'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tender List
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: ListView(
                        children: filteredTenderListData.map((tender) {
                          return GestureDetector(
                            onTap: () {
                              // Navigate to TenderDetails screen with the selected tender data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TenderDetails(data: tender),
                                ),
                              );
                            },
                            child: tenderlistitem(
                              tender['tender_title'] ?? 'No Title',
                              tender['tender_id'] ?? 'No ID',
                              tender['tender_status'] ?? 'No Status',
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Widget to display each tender item
  Widget tenderlistitem(String title, String id, String status) {
    Color statusColor = Colors.grey; // Default color for unknown status
    if (status == 'applied') {
      statusColor = Colors.blue;
    } else if (status == 'completed') {
      statusColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(Icons.assignment, color: statusColor),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
            overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            maxLines: 1, // Limit to one line
          ),
          subtitle: Text(
            "ID: $id",
            style: const TextStyle(color: Colors.black38),
            overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            maxLines: 1, // Limit to one line
          ),
          trailing: SizedBox(
            width: 60, // Fixed width for the status text
            child: Text(
              capitalize(status), // Capitalize the status
              textAlign: TextAlign.right, // or left, right, justify, start, end
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
              maxLines: 1, // Limit to one line
            ),
          ),
        ),
      ),
    );
  }
}
