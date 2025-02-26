import 'package:flutter/material.dart';

class TenderDetails extends StatelessWidget {
  const TenderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> staticData = {
      'tender_id': 'TND-2024023',
      'tender_title': 'Medical Equipment Procurement',
      'issuing_authority': 'Health Ministry',
      'tender_description': 'Procurement of surgical assistance devices.',
      'tender_attachment': 'https://example.com/tender.pdf',
      'emd_amount': '₹50,000',
      'emd_payment_status': 'Paid',
      'emd_payment_mode': 'Online Transfer',
      'emd_payment_date': '2024-02-15',
      'transaction_number': 'TXN123456789',
      'payment_attachment': 'https://example.com/payment_receipt.pdf',
      'forfeiture_status': 'No',
      'forfeiture_reason': 'N/A',
      'emd_refund_status': 'Pending',
      'emd_refund_date': '2024-06-30',
      'bid_amount': '₹750,000',
      'bid_outcome': 'Awaiting Results'
    };

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
            Text(staticData['tender_title'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Tender ID: ${staticData['tender_id']}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildDetailRow(
                "Issuing Authority", staticData['issuing_authority']),
            _buildDetailRow(
                "Tender Description", staticData['tender_description']),
            _buildDetailRow("EMD Amount", staticData['emd_amount']),
            _buildDetailRow(
                "EMD Payment Status", staticData['emd_payment_status']),
            _buildDetailRow("EMD Payment Mode", staticData['emd_payment_mode']),
            _buildDetailRow("EMD Payment Date", staticData['emd_payment_date']),
            _buildDetailRow(
                "Transaction Number", staticData['transaction_number']),
            _buildDetailRow(
                "Forfeiture Status", staticData['forfeiture_status']),
            _buildDetailRow(
                "Forfeiture Reason", staticData['forfeiture_reason']),
            _buildDetailRow(
                "EMD Refund Status", staticData['emd_refund_status']),
            _buildDetailRow("EMD Refund Date", staticData['emd_refund_date']),
            _buildDetailRow("Bid Amount", staticData['bid_amount']),
            _buildDetailRow("Bid Outcome", staticData['bid_outcome']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAttachmentDialog(
                  context, staticData['tender_attachment']),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View Tender Attachment"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _showAttachmentDialog(
                  context, staticData['payment_attachment']),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View Payment Attachment"),
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
