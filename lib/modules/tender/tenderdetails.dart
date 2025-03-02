import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TenderDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const TenderDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tender Details"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(data['tender_title'] ?? 'No Title',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Tender ID: ${data['tender_id'] ?? 'No ID'}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildDetailRow("Issuing Authority", data['issuing_authority']),
            _buildDetailRow("Tender Description", data['tender_description']),
            _buildDetailRow("EMD Amount", data['EMD_amount']),
            _buildDetailRow("EMD Payment Status", data['EMD_payment_status']),
            _buildDetailRow("EMD Payment Mode", data['EMD_payment_mode']),
            _buildDetailRow("EMD Payment Date", data['EMD_payment_date']),
            _buildDetailRow("Transaction Number", data['transaction_number']),
            _buildDetailRow("Forfeiture Status", data['forfeiture_status']),
            _buildDetailRow("Forfeiture Reason", data['forfeiture_reason']),
            _buildDetailRow("EMD Refund Status", data['EMD_refund_status']),
            _buildDetailRow("EMD Refund Date", data['EMD_refund_date']),
            _buildDetailRow("Bid Amount", data['bid_amount']),
            _buildDetailRow("Bid Outcome", data['bid_outcome']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAttachmentDialog(context, data['tender_attachment']),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View Tender Attachment"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAttachmentDialog(context, data['payment_attachment']),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View Payment Attachment"),
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
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            flex: 1,
            child: Text(value?.toString() ?? 'N/A',
                style: const TextStyle(fontSize: 16)),
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
                onPressed: () async {
                  final Uri url = Uri.parse(attachmentUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("No app found to open the PDF")),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("Open PDF in External App"),
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
