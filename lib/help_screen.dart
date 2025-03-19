import 'package:flutter/material.dart';
import 'package:track_in/FAQ_screen.dart';
import 'package:track_in/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'security_screen.dart'; // Import the SecurityScreen

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back arrow color to white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Topics Section
            Text(
              "Help Topics",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildHelpTopic(
              icon: Icons.account_circle,
              title: "Account Settings",
              onTap: () {
                // Navigate to Account Settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            _buildHelpTopic(
              icon: Icons.lock,
              title: "Password & Security",
              onTap: () {
                // Navigate to Security Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  ),
                );
              },
            ),
            _buildHelpTopic(
              icon: Icons.help_outline,
              title: "General FAQs",
              onTap: () {
                // Navigate to General FAQs screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FAQsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Contact Support Section
            Text(
              "Contact Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildContactSupportOption(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "meddocxinc@gmail.com",
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'meddocxinc@gmail.com',
                  queryParameters: {
                    'subject': 'Support Request',
                    'body': 'Hello, I need help with...',
                  },
                );
                if (await canLaunch(emailUri.toString())) {
                  await launch(emailUri.toString());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Could not open email app."),
                    ),
                  );
                }
              },
            ),
            _buildContactSupportOption(
              icon: Icons.phone,
              title: "Call Support",
              subtitle: "+91 7907693769",
              onTap: () async {
                final Uri phoneUri = Uri(
                  scheme: 'tel',
                  path: '+917907693769',
                );
                if (await canLaunch(phoneUri.toString())) {
                  await launch(phoneUri.toString());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Could not open phone app."),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a help topic
  Widget _buildHelpTopic({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Helper method to build a contact support option
  Widget _buildContactSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
