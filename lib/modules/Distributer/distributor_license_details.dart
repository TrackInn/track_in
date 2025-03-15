import 'package:flutter/material.dart';

class DistributerLicenseDetails extends StatefulWidget {
  final Map data;

  const DistributerLicenseDetails({super.key, required this.data});

  @override
  _DistributerLicenseDetailsState createState() =>
      _DistributerLicenseDetailsState();
}

class _DistributerLicenseDetailsState extends State<DistributerLicenseDetails> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.data['product_name'] ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("License No: ${widget.data['license_number'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow(
                      "Type of Application", widget.data['application_type']),
                  _buildDetailRow(
                      "Application No.", widget.data['application_number']),
                  _buildDetailRow("License No.", widget.data['license_number']),
                  _buildDetailRow(
                      "Date of Submission", widget.data['date_of_submission']),
                  _buildDetailRow(
                      "Date of Approval", widget.data['date_of_approval']),
                  _buildDetailRow("Expiry Date", widget.data['expiry_date']),
                  _buildDetailRow("Product Type", widget.data['product_type']),
                  _buildDetailRow("Product Name", widget.data['product_name']),
                  _buildDetailRow("Model Number", widget.data['model_number']),
                  _buildDetailRow("Intended Use", widget.data['intended_use']),
                  _buildDetailRow(
                      "Class of Device", widget.data['class_of_device_type']),
                  _buildDetailRow(
                      "Software Used", widget.data['software'] ? "Yes" : "No"),
                  _buildDetailRow(
                      "Legal Manufacturer", widget.data['legal_manufacturer']),
                  _buildDetailRow(
                      "Agent Address", widget.data['agent_address']),
                  _buildDetailRow("Accessories", widget.data['accesories']),
                  _buildDetailRow(
                      "Shelf Life", "${widget.data['shelf_life']} years"),
                  _buildDetailRow(
                      "Pack Size", "${widget.data['pack_size']} pcs"),
                  const SizedBox(height: 20),
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
