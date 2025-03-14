import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TenderDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const TenderDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isApplied = data['tender_status'] == 'applied';
    final bool isPaymentModeOffline = data['EMD_payment_mode'] == 'offline';
    final bool isRefundStatusNo =
        data['EMD_refund_status'] == false || data['EMD_refund_status'] == null;
    final bool isForfeitureStatusNo =
        data['forfeiture_status'] == false || data['forfeiture_status'] == null;

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
            _buildDetailRow(
                "Tender Handler", data['tender_handler'] ?? 'Not specified'),
            _buildDetailRow("Tender Description", data['tender_description']),
            _buildDetailRow("EMD Amount", data['EMD_amount'] ?? 'N/A'),
            _buildDetailRow(
                "EMD Payment Mode", _capitalize(data['EMD_payment_mode'])),
            _buildDetailRow("EMD Payment Date", data['EMD_payment_date']),
            if (!isPaymentModeOffline)
              _buildDetailRow("Transaction Number", data['transaction_number']),
            _buildDetailRow(
                "Tender Status", _formatTenderStatus(data['tender_status'])),
            if (!isApplied) ...[
              _buildDetailRow(
                  "Forfeiture Status", _formatBool(data['forfeiture_status'])),
              if (!isForfeitureStatusNo)
                _buildDetailRow("Forfeiture Reason", data['forfeiture_reason']),
              _buildDetailRow(
                  "EMD Refund Status", _formatBool(data['EMD_refund_status'])),
              if (!isRefundStatusNo)
                _buildDetailRow("EMD Refund Date", data['EMD_refund_date']),
              _buildDetailRow("Bid Outcome", _capitalize(data['bid_outcome'])),
            ],
            const SizedBox(height: 20),
            if (data['tender_attachments'] != null)
              ElevatedButton.icon(
                onPressed: () =>
                    _showAttachmentDialog(context, data['tender_attachments']),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("View Tender Attachment"),
              ),
            const SizedBox(height: 10),
            if (!isPaymentModeOffline && data['payment_attachments'] != null)
              ElevatedButton.icon(
                onPressed: () =>
                    _showAttachmentDialog(context, data['payment_attachments']),
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

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatBool(bool? value) {
    if (value == null) return 'N/A';
    return value ? 'Yes' : 'No';
  }

  String _formatTenderStatus(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    if (value == 'Not_declared') return 'Not declared';
    return _capitalize(value);
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
