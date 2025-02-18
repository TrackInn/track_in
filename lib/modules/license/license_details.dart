import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class LicenseDetailScreen extends StatelessWidget {
  final Map data;

  const LicenseDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("License Details"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['product_name'] ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("License No: ${data['license_number'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow(
                      "Type of Application", data['application_type']),
                  _buildDetailRow(
                      "Application No.", data['application_number']),
                  _buildDetailRow("License No.", data['license_number']),
                  _buildDetailRow(
                      "Date of Submission", data['date_of_submission']),
                  _buildDetailRow("Date of Approval", data['date_of_approval']),
                  _buildDetailRow("Expiry Date", data['expiry_date']),
                  _buildDetailRow("Product Type", data['product_type']),
                  _buildDetailRow("Product Name", data['product_name']),
                  _buildDetailRow("Model Number", data['model_number']),
                  _buildDetailRow("Intended Use", data['intended_use']),
                  _buildDetailRow(
                      "Class of Device", data['class_of_device_type']),
                  _buildDetailRow(
                      "Software Used", data['software'] ? "Yes" : "No"),
                  _buildDetailRow(
                      "Legal Manufacturer", data['legal_manufacturer']),
                  _buildDetailRow("Agent Address", data['agent_address']),
                  _buildDetailRow("Accessories", data['accesories']),
                  _buildDetailRow("Shell Life", "${data['shell_life']} years"),
                  _buildDetailRow("Pack Size", "${data['pack_size']} pcs"),
                  const SizedBox(height: 20),
                  if (data['attachments'] != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle attachment viewing
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("View Attachment"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAttachmentDialog(BuildContext context, String attachmentUrl) {
  bool isPdf = attachmentUrl.toLowerCase().endsWith('.pdf');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Attachment"),
        content: isPdf
            ? SizedBox(
                height: 400,
                child: PdfViewerPage(pdfUrl: attachmentUrl),
              )
            : Image.network(
                attachmentUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Text("Failed to load image"),
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

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: PDFView(
        filePath: pdfUrl, // Ensure it's a local file
      ),
    );
  }
}
