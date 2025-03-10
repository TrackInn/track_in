import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNotificationScreen extends StatefulWidget {
  final int notificationId; // ID of the notification to be edited

  const EditNotificationScreen({super.key, required this.notificationId});

  @override
  _EditNotificationScreenState createState() => _EditNotificationScreenState();
}

class _EditNotificationScreenState extends State<EditNotificationScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotificationDetails(); // Fetch notification details when the screen is loaded
  }

  // Fetch notification details from the API
  Future<void> fetchNotificationDetails() async {
    final String apiUrl = '$baseurl/updatenotification/';

    try {
      final response = await http.get(
        Uri.parse('$apiUrl${widget.notificationId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          titleController.text = responseData['title'];
          contentController.text = responseData['content'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch notification details')),
        );
      }
    } catch (e) {
      print("Error fetching notification details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch notification details')),
      );
    }
  }

  // Update notification using the API
  Future<void> updateNotification() async {
    // Retrieve logged-in user details from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userDetails = json.decode(prefs.getString('userDetails')!);

    final int loggedInProfileId = userDetails['id']; // Sender's profile ID

    final String apiUrl = '$baseurl/updatenotification/';

    final Map<String, dynamic> requestBody = {
      'id': widget.notificationId, // Notification ID
      'profile': loggedInProfileId, // Sender's profile ID
      'title': titleController.text,
      'content': contentController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification updated successfully!')),
        );
      } else {
        // Error
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update notification: ${responseData['msg']}')),
        );
      }
    } catch (e) {
      print("Error updating notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update notification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active,
                      size: 40, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Edit Notification',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedTextField('Notification title',
                  controller: titleController),
              const SizedBox(height: 15),
              _buildAnimatedTextField('Notification content',
                  controller: contentController, maxLines: 3, alignTop: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: updateNotification,
                  child: const Text('Update notification',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField(String label,
      {int maxLines = 1,
      bool alignTop = false,
      TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 10, vertical: alignTop ? 10 : 12),
            alignLabelWithHint: alignTop,
          ),
        ),
      ],
    );
  }
}
