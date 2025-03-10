import 'package:flutter/material.dart';
import 'package:track_in/modules/license/edit_license.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';
import 'package:track_in/modules/license/license_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class LicenseDetailScreen extends StatefulWidget {
  final Map data;

  const LicenseDetailScreen({super.key, required this.data});

  @override
  _LicenseDetailScreenState createState() => _LicenseDetailScreenState();
}

class _LicenseDetailScreenState extends State<LicenseDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _translateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _deleteLicense() async {
    final licenseId = widget.data['id'];
    print(licenseId);
    final url = Uri.parse('$baseurl/edit/?id=$licenseId');

    final id = {'id': licenseId.toString()};

    final response = await http.delete(url, body: json.encode(id));
    print('==================================================');

    print(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License deleted successfully')),
      );
      Navigator.of(context).pop(); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete license: ${response.body}')),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this license?"),
          actions: [
            // Cancel Button with Capsule-like Border
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200], // Light grey background
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(24), // Capsule-like border
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black), // Black text
              ),
            ),
            // Delete Button with Capsule-like Border
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteLicense();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[400], // Red background
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(24), // Capsule-like border
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white), // White text
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PDFDocument? doc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("License Details"),
        backgroundColor: Colors.blue,
        foregroundColor:
            Colors.white, // Set app bar text and back button color to white
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
                  if (widget.data['attachments'] != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PDFViwerScreen(
                                    url:
                                        baseurl + widget.data['attachments'])));
                        print(baseurl + widget.data['attachments']);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("View Attachment"),
                    ),
                  if (doc != null)
                    PDFViewer(
                        document: doc!,
                        lazyLoad: false,
                        zoomSteps: 1,
                        numberPickerConfirmWidget: const Text(
                          "Confirm",
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isExpanded)
            Transform.translate(
              offset: Offset(-60 * _translateAnimation.value,
                  -50 * _translateAnimation.value),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditLicenseScreen(data: widget.data),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  mini: true,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.edit), // Ensure circular shape
                ),
              ),
            ),
          if (_isExpanded) const SizedBox(height: 10),
          if (_isExpanded)
            Transform.translate(
              offset: Offset(25 * _translateAnimation.value,
                  -50 * _translateAnimation.value),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FloatingActionButton(
                  onPressed: _showDeleteConfirmationDialog,
                  backgroundColor: Colors.red,
                  mini: true,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.delete), // Ensure circular shape
                ),
              ),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _toggleExpansion,
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: RotationTransition(
              turns: _rotationAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: _isExpanded
                    ? const Icon(Icons.close, key: ValueKey('close'))
                    : const Icon(Icons.more_vert, key: ValueKey('more_vert')),
              ),
            ), // Ensure circular shape
          ),
        ],
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
  final fullUrl =
      'https://icseindia.org/document/sample.pdf'; // Replace with the new URL
  print("Full URL: $fullUrl"); // Print the full URL for debugging

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
                final Uri url = Uri.parse(fullUrl);
                print("Launching URL: $url"); // Debugging
                if (await canLaunchUrl(url)) {
                  // Open the URL in an external app
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication, // Force external app
                  );
                } else {
                  print("No app found to handle the URL: $url"); // Debugging
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No app found to open the PDF")),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
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
