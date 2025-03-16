import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart'; // Replace with your actual base URL import

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  String _biometricMessage = "Checking security options...";
  String _selectedSecurityOption = 'screen_lock'; // Default to Screen Lock
  bool _isBiometricActive = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadSecurityPreference();
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
            ? "Security options are available."
            : "Screen Lock is not available. Ensure your device has security features (e.g., PIN, pattern, password, or biometrics) enabled.";
      });
    } catch (e) {
      print("Error checking biometric support: $e");
      setState(() {
        _biometricMessage = "Error checking security options: $e";
      });
    }
  }

  // Load security preference from SharedPreferences
  Future<void> _loadSecurityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSecurityOption =
          prefs.getString('securityOption') ?? 'screen_lock';
      _isBiometricActive = prefs.getBool('isBiometricActive') ?? false;
    });
  }

  // Save security preference to SharedPreferences
  Future<void> _saveSecurityPreference(String option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('securityOption', option);
  }

  // Toggle Screen Lock
  Future<void> _toggleScreenLock(bool value) async {
    if (_isBiometricActive) {
      // Disable Screen Lock
      setState(() {
        _isBiometricActive = false;
      });
      await _saveSecurityPreference('none');
    } else {
      // Enable Screen Lock
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable Screen Lock',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _isBiometricActive = true;
          _selectedSecurityOption = 'screen_lock';
        });
        await _saveSecurityPreference('screen_lock');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen Lock enabled!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen Lock setup failed.')),
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
        return StatefulBuilder(
          builder: (context, setState) {
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
                          // Toggle current password visibility
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
                          // Toggle new password visibility
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
      },
    );
  }

  // Function to call the API for changing the password using GET
  Future<Map<String, dynamic>> _changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = json.decode(prefs.getString('userDetails') ?? '{}');
    final profileId = userDetails['id'];

    try {
      // Construct the URL with query parameters
      final url = Uri.parse('$baseurl/editpassword/').replace(
        queryParameters: {
          'profile_id': profileId.toString(),
          'password': currentPassword,
          'new_password': newPassword,
        },
      );

      // Use GET method
      final response = await http.get(url);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Section
            Text(
              "Security",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Set your preference to protect your app data using Screen Lock or a 4-digit PIN to secure access to your account.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Radio Buttons for Security Options
            Column(
              children: [
                // Screen Lock Option
                ListTile(
                  title: const Text("Use Screen Lock"),
                  subtitle: Text(
                    _isBiometricEnabled
                        ? "Use your existing PIN, pattern, password, or biometrics (e.g., fingerprint or face ID) linked to your device."
                        : "Screen Lock is not available on this device.",
                    style: TextStyle(
                      color:
                          _isBiometricEnabled ? Colors.grey[600] : Colors.red,
                    ),
                  ),
                  leading: Radio(
                    value: 'screen_lock',
                    groupValue: _selectedSecurityOption,
                    onChanged: _isBiometricEnabled
                        ? (value) {
                            setState(() {
                              _selectedSecurityOption = value.toString();
                            });
                            _toggleScreenLock(true);
                          }
                        : null,
                  ),
                ),
                // 4-Digit PIN Option
                ListTile(
                  title: const Text("Use 4-Digit PIN"),
                  subtitle: const Text(
                    "Use a 4-digit PIN to protect your data.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  leading: Radio(
                    value: '4_digit_pin',
                    groupValue: _selectedSecurityOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedSecurityOption = value.toString();
                      });
                      _saveSecurityPreference('4_digit_pin');
                    },
                  ),
                ),
              ],
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
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showChangePasswordDialog(context);
                  },
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Password Field with *****
            TextField(
              obscureText: true,
              enabled: false, // Disable editing
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: '********', // Placeholder for password
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
