import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/modules/PNDT/edit_pndt.dart';
import 'package:track_in/baseurl.dart'; // Ensure this import is correct for your base URL
import 'package:track_in/pdf_view.dart'; // Import the PDF viewer screen

class PndtDetails extends StatefulWidget {
  final Map<String, dynamic> licenseData;

  const PndtDetails({super.key, required this.licenseData});

  @override
  _PndtDetailsState createState() => _PndtDetailsState();
}

class _PndtDetailsState extends State<PndtDetails>
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
    final String licenseNumber = widget.licenseData['license_number'];
    print(licenseNumber);
    final String apiUrl =
        "$baseurl/updatepndtlicense/?license_number=$licenseNumber";
    print(apiUrl);
    try {
      final response = await http.delete(Uri.parse(apiUrl));

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
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
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
              onPressed: () {
                // Remove '/api' from baseurl for the PDF URL
                final baseUrlWithoutApi = baseurl.replaceAll('/api', '');
                final pdfUrl =
                    baseUrlWithoutApi + widget.licenseData['attachments'];
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PDFViwerScreen(url: pdfUrl)));
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View Attachment"),
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
                            EditPNDTLicenseScreen(data: widget.licenseData),
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
}
