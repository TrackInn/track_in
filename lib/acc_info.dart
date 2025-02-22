import 'package:flutter/material.dart';

class EditAccountInformationScreen extends StatelessWidget {
  const EditAccountInformationScreen({super.key});

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
            _buildInfoText("abintomy22cs@ilssah.com"),
            _buildChangeButton("Change Username", onPressed: () {
              _showChangeUsernameDialog(context);
            }),
            const SizedBox(height: 20),

            // Email Section
            _buildSectionTitle("Email"),
            _buildInfoText("abintomy22cs@ilssah.com"),
            _buildChangeButton("Change Email", onPressed: () {
              _showChangeEmailDialog(context);
            }),
            const SizedBox(height: 20),

            // Password Section
            _buildSectionTitle("Password"),
            _buildInfoText("**********"),
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
                      obscurePassword = !obscurePassword;
                      (context as Element).markNeedsBuild(); // Update the UI
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
                print("Verify and change username");
                Navigator.pop(context); // Close the dialog
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

  // Function to show the "Change Email" dialog
  void _showChangeEmailDialog(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    bool obscurePassword = true; // To toggle password visibility

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Change Email",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      obscurePassword = !obscurePassword;
                      (context as Element).markNeedsBuild(); // Update the UI
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your current password to change your email.",
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
                // Add functionality to verify and change email
                print("Verify and change email");
                Navigator.pop(context); // Close the dialog
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
                      obscurePassword = !obscurePassword;
                      (context as Element).markNeedsBuild(); // Update the UI
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
              onPressed: () {
                // Add functionality to verify and change password
                print("Verify and change password");
                Navigator.pop(context); // Close the dialog
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
}
