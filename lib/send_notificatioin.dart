import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SendNotificationScreen(),
  ));
}

class SendNotificationScreen extends StatelessWidget {
  const SendNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
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
                    'Send Notification',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedTextField('Notification title'),
              const SizedBox(height: 15),
              _buildAnimatedTextField('Notification content',
                  maxLines: 3, alignTop: true),
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
                  onPressed: () {},
                  child: const Text('Send notification',
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
      {int maxLines = 1, bool alignTop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        TextField(
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
