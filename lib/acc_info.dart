import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart'; // Ensure this file contains the base URL

class EditAccountInformationScreen extends StatefulWidget {
  final Map<String, dynamic>? userDetails;

  const EditAccountInformationScreen({super.key, this.userDetails});

  @override
  _EditAccountInformationScreenState createState() =>
      _EditAccountInformationScreenState();
}

class _EditAccountInformationScreenState
    extends State<EditAccountInformationScreen> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userDetails?['username']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Account Information",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Section
            _buildSectionTitle("Username"),
            _buildInfoText(_usernameController.text),
            _buildChangeButton("Change Username", onPressed: () {
              _showChangeUsernameDialog(context);
            }),
            const SizedBox(height: 20),

            // Email Section (Unchangeable)
            _buildSectionTitle("Email"),
            _buildInfoText(widget.userDetails?['email'] ?? "N/A"),
            const SizedBox(height: 20),

            // Role Section (Unchangeable)
            _buildSectionTitle("Role"),
            _buildInfoText(widget.userDetails?['role'] ?? "N/A"),
          ],
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  // Helper method to build information text
  Widget _buildInfoText(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper method to build the "Change" button
  Widget _buildChangeButton(String label, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.1),
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(label),
    );
  }

  // Function to show the "Change Username" dialog
  void _showChangeUsernameDialog(BuildContext context) {
    TextEditingController newUsernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Change Username",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // New Username Field
              TextField(
                controller: newUsernameController,
                decoration: InputDecoration(
                  labelText: "New Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your new username.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call the API to change the username
                final newUsername = newUsernameController.text;

                // Convert profileId to String
                final profileId = widget.userDetails?['id'].toString();

                final response = await _changeUsername(
                  profileId: profileId,
                  newUsername: newUsername,
                );

                if (response['success']) {
                  setState(() {
                    _usernameController.text = newUsername;
                  });
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['msg']),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['msg']),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Change"),
            ),
          ],
        );
      },
    );
  }

  // Function to call the API for changing the username
  Future<Map<String, dynamic>> _changeUsername({
    required String? profileId,
    required String newUsername,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseurl/change-username/'), // Update the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'profile_id': profileId,
          'new_username': newUsername,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': 'Username changed successfully',
        };
      } else {
        return {
          'success': false,
          'msg': 'Failed to change username: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'msg': 'An error occurred: $e',
      };
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
