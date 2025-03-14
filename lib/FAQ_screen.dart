import 'package:flutter/material.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "General FAQs",
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
          children: [
            _buildFAQItem(
              question: "How do I reset my password?",
              answer:
                  "To reset your password, go to the 'Password & Security' section in the app and follow the instructions.",
            ),
            _buildFAQItem(
              question: "How do I update my account information?",
              answer:
                  "You can update your account information in the 'Account Settings' section.",
            ),
            _buildFAQItem(
              question: "What should I do if I forget my email?",
              answer:
                  "If you forget your email, contact our support team at trackinn69@gmail.com.",
            ),
            _buildFAQItem(
              question: "How do I contact support?",
              answer:
                  "You can contact support via email (trackinn69@gmail.com) or phone (+91 7907693769).",
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build an FAQ item
  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
