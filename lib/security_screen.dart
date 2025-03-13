import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _isBiometricActive = false;
  String _biometricMessage = "Checking biometric support...";

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadBiometricState();
  }

  // Check if biometric authentication is supported
  Future<void> _checkBiometricSupport() async {
    try {
      print("Checking biometric support...");

      // Check if biometric authentication is supported
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      print("Can check biometrics: $canCheckBiometrics");

      // Get available biometric types
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      print("Available biometrics: $availableBiometrics");

      setState(() {
        _isBiometricEnabled =
            canCheckBiometrics && availableBiometrics.isNotEmpty;
        _biometricMessage = _isBiometricEnabled
            ? "Biometric authentication is available."
            : "Biometric authentication is not available. Ensure your device has biometric hardware (e.g., fingerprint or face recognition) and that you have enrolled biometrics.";
      });
    } catch (e) {
      print("Error checking biometric support: $e");
      setState(() {
        _biometricMessage = "Error checking biometric support: $e";
      });
    }
  }

  // Load biometric authentication state from SharedPreferences
  Future<void> _loadBiometricState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricActive = prefs.getBool('isBiometricActive') ?? false;
    });
  }

  // Save biometric authentication state to SharedPreferences
  Future<void> _saveBiometricState(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricActive', isActive);
  }

  // Toggle biometric authentication
  Future<void> _toggleBiometricAuth(bool value) async {
    if (_isBiometricActive) {
      // Disable biometric authentication
      setState(() {
        _isBiometricActive = false;
      });
      await _saveBiometricState(false);
    } else {
      // Enable biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric authentication',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _isBiometricActive = true;
        });
        await _saveBiometricState(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication enabled!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed.')),
        );
      }
    }
  }

  // Show the change password dialog
  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;

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
              // Current Password Field
              TextField(
                controller: currentPasswordController,
                obscureText: obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureCurrentPassword = !obscureCurrentPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // New Password Field
              TextField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                  ),
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
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;

                // Retrieve the stored password from SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                final storedPassword = prefs.getString('password');

                // Verify the current password
                if (currentPassword != storedPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect current password')),
                  );
                  return;
                }

                // Call the API to change the password
                final response = await _changePassword(
                  currentPassword: currentPassword,
                  newPassword: newPassword,
                );

                if (response['success']) {
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['msg'])),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['msg'])),
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

  // Function to call the API for changing the password
  Future<Map<String, dynamic>> _changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = json.decode(prefs.getString('userDetails') ?? '{}');
    final profileId = userDetails['id'];

    try {
      final response = await http.post(
        Uri.parse('$baseurl/editpassword/'), // Update the URL
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Security Settings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biometric Authentication Section
            Text(
              "Biometric Authentication",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _biometricMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _isBiometricActive,
              onChanged: _isBiometricEnabled
                  ? (value) => _toggleBiometricAuth(value)
                  : null,
              activeColor: Colors.blue,
              title: const Text("Enable Biometric Authentication"),
              subtitle: !_isBiometricEnabled
                  ? const Text(
                      "Biometric authentication is not available on this device.",
                      style: TextStyle(color: Colors.red),
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            // Change Password Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showChangePasswordDialog(context);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Change Password"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
