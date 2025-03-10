import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_in/baseurl.dart'; // Import your base URL

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  // Controllers for text fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController feedbackController;

  // Variable to store the logged-in user's email
  String loggedInUserEmail = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    feedbackController = TextEditingController();

    // Fetch the logged-in user's email from SharedPreferences
    _fetchUserEmail();
  }

  // Function to fetch the logged-in user's email
  Future<void> _fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('userDetails');

    if (userDetails != null) {
      final user = json.decode(userDetails);
      setState(() {
        loggedInUserEmail = user['email'];
        emailController.text = loggedInUserEmail; // Pre-fill the email field
      });
    }
  }

  // Function to submit feedback
  Future<void> submitFeedback() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String feedback = feedbackController.text;

    // Validate fields
    if (name.isEmpty || email.isEmpty || feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Prepare the API URL
    final Uri url = Uri.parse('$baseurl/feedback/');

    try {
      // Make the POST request
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'message': feedback,
        }),
      );

      // Handle the response
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
        // Clear the text fields
        nameController.clear();
        feedbackController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit feedback: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
            Navigator.pop(context);
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
                  Icon(Icons.feedback, size: 40, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Send Feedback',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedTextField('Your Name', controller: nameController),
              const SizedBox(height: 15),
              _buildAnimatedTextField(
                'Your Email',
                controller: emailController,
                enabled: false, // Disable the email field
              ),
              const SizedBox(height: 15),
              _buildAnimatedTextField('Your Feedback',
                  maxLines: 4, alignTop: true, controller: feedbackController),
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
                  onPressed: submitFeedback,
                  child: const Text('Submit Feedback',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildAnimatedTextField(String label,
      {int maxLines = 1,
      bool alignTop = false,
      TextEditingController? controller,
      bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled, // Control whether the field is editable
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
