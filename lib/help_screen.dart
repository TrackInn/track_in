import 'package:flutter/material.dart';

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
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            _buildHelpTopic(
              icon: Icons.account_circle,
              title: "Account Settings",
              onTap: () {
                // Navigate to account settings help
              },
            ),
            _buildHelpTopic(
              icon: Icons.lock,
              title: "Password & Security",
              onTap: () {
                // Navigate to password & security help
              },
            ),
            _buildHelpTopic(
              icon: Icons.help_outline,
              title: "General FAQs",
              onTap: () {
                // Navigate to general FAQs
              },
            ),
            const SizedBox(height: 20),

            // Contact Support Section
            Text(
              "Contact Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            _buildContactSupportOption(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "support@trackin.com",
              onTap: () {
                // Open email client
              },
            ),
            _buildContactSupportOption(
              icon: Icons.phone,
              title: "Call Support",
              subtitle: "+1 123 456 7890",
              onTap: () {
                // Open phone dialer
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
            color: Colors.blue[800],
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
            color: Colors.blue[800],
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
