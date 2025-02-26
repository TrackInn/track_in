import 'package:flutter/material.dart';

class PndtDetails extends StatelessWidget {
  const PndtDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> staticData = {
      'license_number': '12345-ABC',
      'application_number': 'A-98765',
      'submission_date': '2023-05-01',
      'expiry_date': '2028-06-15',
      'approval_date': '2023-06-15',
      'product_type': 'Medical Equipment',
      'product_name': 'Medical Device X',
      'model_number': 'MDX-2023',
      'intended_use': 'Surgical Assistance',
      'class_of_device': 'Class II',
      'software_used': true,
      'legal_manufacturer': 'HealthTech Corp.',
      'authorized_agent_address': '1234 Elm Street, NY',
      'attachments': 'https://icseindia.org/document/sample.pdf'
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("License Details"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(staticData['product_name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("License No: ${staticData['license_number']}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildDetailRow(
                "Application Number", staticData['application_number']),
            _buildDetailRow("Submission Date", staticData['submission_date']),
            _buildDetailRow("Approval Date", staticData['approval_date']),
            _buildDetailRow("Expiry Date", staticData['expiry_date']),
            _buildDetailRow("Product Type", staticData['product_type']),
            _buildDetailRow("Model Number", staticData['model_number']),
            _buildDetailRow("Intended Use", staticData['intended_use']),
            _buildDetailRow("Class of Device", staticData['class_of_device']),
            _buildDetailRow(
                "Software Used", staticData['software_used'] ? "Yes" : "No"),
            _buildDetailRow(
                "Legal Manufacturer", staticData['legal_manufacturer']),
            _buildDetailRow("Authorized Agent Address",
                staticData['authorized_agent_address']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAttachmentDialog(context, staticData['attachments']),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View Attachment"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            flex: 1,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showAttachmentDialog(BuildContext context, String attachmentUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Attachment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "Click the button below to open the PDF in an external app."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Open PDF"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
