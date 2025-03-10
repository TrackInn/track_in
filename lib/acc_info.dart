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
  late TextEditingController _passwordController;

  // Define the API endpoint
  final String apiUrl = '$baseurl/editpassword/';

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userDetails?['username']);
    _passwordController = TextEditingController(text: "********");
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
            const SizedBox(height: 20),

            // Password Section
            _buildSectionTitle("Password"),
            _buildInfoText(_passwordController.text),
            _buildChangeButton("Change Password", onPressed: () {
              _showChangePasswordDialog(context);
            }),
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
    TextEditingController currentPasswordController = TextEditingController();
    bool obscurePassword = true; // To toggle password visibility

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
              SizedBox(height: 10),
              // Password Field with Eye Icon
              TextField(
                controller: currentPasswordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your current password to change your username.",
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
              onPressed: () {
                // Add functionality to verify and change username
                final newUsername = newUsernameController.text;
                final currentPassword = currentPasswordController.text;

                // Verify the current password (you can add your logic here)
                if (currentPassword == "current_password") {
                  setState(() {
                    _usernameController.text = newUsername;
                  });
                  Navigator.pop(context); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Incorrect current password"),
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
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  // Function to show the "Change Password" dialog
  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController currentPasswordController = TextEditingController();
    bool obscurePassword = true; // To toggle password visibility

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Change Password",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // New Password Field
              TextField(
                controller: newPasswordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Current Password Field
              TextField(
                controller: currentPasswordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your current password to change your password.",
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
                // Add functionality to verify and change password
                final newPassword = newPasswordController.text;
                final currentPassword = currentPasswordController.text;

                // Convert profileId to String
                final profileId = widget.userDetails?['id'].toString();

                // Call the API to change the password
                final response = await _changePassword(
                  profileId: profileId, // Pass the converted profileId
                  currentPassword: currentPassword,
                  newPassword: newPassword,
                );

                if (response['success']) {
                  setState(() {
                    _passwordController.text = newPassword;
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
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  // Function to call the API for changing the password
  Future<Map<String, dynamic>> _changePassword({
    required String? profileId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'profile_id': profileId,
          'password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'msg': 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'msg': 'Failed to change password: ${response.body}',
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
    _passwordController.dispose();
    super.dispose();
  }
}
