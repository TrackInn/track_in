import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart'; // Ensure this import is correct for your base URL

class PndtDetails extends StatefulWidget {
  final Map<String, dynamic> licenseData;

  const PndtDetails({super.key, required this.licenseData});

  @override
  _PndtDetailsState createState() => _PndtDetailsState();
}

class _PndtDetailsState extends State<PndtDetails> {
  @override
  Widget build(BuildContext context) {
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
            Text(widget.licenseData['product_name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("License No: ${widget.licenseData['license_number']}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildDetailRow(
                "license_number", widget.licenseData['license_number']),
            _buildDetailRow(
                "Application Number", widget.licenseData['application_number']),
            _buildDetailRow(
                "Submission Date", widget.licenseData['submission_date']),
            _buildDetailRow(
                "Approval Date", widget.licenseData['approval_date']),
            _buildDetailRow("Expiry Date", widget.licenseData['expiry_date']),
            _buildDetailRow("Product Type", widget.licenseData['product_type']),
            _buildDetailRow("Product Name", widget.licenseData['product_name']),
            _buildDetailRow("Model Number", widget.licenseData['model_number']),
            _buildDetailRow(
                "State", widget.licenseData['state']), // Add this line
            _buildDetailRow("Intended Use", widget.licenseData['intended_use']),
            _buildDetailRow(
                "Class of Device", widget.licenseData['class_of_device']),
            _buildDetailRow(
                "Software Used", widget.licenseData['software'] ? "Yes" : "No"),
            _buildDetailRow(
                "Legal Manufacturer", widget.licenseData['legal_manufacturer']),
            _buildDetailRow("Authorized Agent Address",
                widget.licenseData['authorize_agent_address']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAttachmentDialog(
                  context, widget.licenseData['attachments']),
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
