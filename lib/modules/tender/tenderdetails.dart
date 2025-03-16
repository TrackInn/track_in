import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/modules/tender/tender_edit.dart';
import 'package:track_in/baseurl.dart'; // Import the base URL
import 'package:track_in/pdf_view.dart'; // Import the PDF viewer screen

class TenderDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const TenderDetails({super.key, required this.data});

  @override
  _TenderDetailsState createState() => _TenderDetailsState();
}

class _TenderDetailsState extends State<TenderDetails>
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

  // Function to delete tender
  Future<void> _deleteTender() async {
    final tenderId = widget.data['tender_id']; // Get tender_id from the data

    try {
      final response = await http.delete(
        Uri.parse('$baseurl/updatetender/?tender_id=$tenderId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tender deleted successfully!")),
        );
        Navigator.of(context).pop(); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete tender: ${response.body}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this tender?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteTender(); // Call the delete function
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
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
    final bool isApplied = widget.data['tender_status'] == 'applied';
    final bool isPaymentModeOffline =
        widget.data['EMD_payment_mode'] == 'offline';
    final bool isRefundStatusNo = widget.data['EMD_refund_status'] == false ||
        widget.data['EMD_refund_status'] == null;
    final bool isForfeitureStatusNo =
        widget.data['forfeiture_status'] == false ||
            widget.data['forfeiture_status'] == null;

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
            Text(widget.data['tender_title'] ?? 'No Title',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Tender ID: ${widget.data['tender_id'] ?? 'No ID'}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildDetailRow(
                "Issuing Authority", widget.data['issuing_authority']),
            _buildDetailRow("Tender Handler",
                widget.data['tender_handler'] ?? 'Not specified'),
            _buildDetailRow(
                "Tender Description", widget.data['tender_description']),
            _buildDetailRow("EMD Amount", widget.data['EMD_amount'] ?? 'N/A'),
            _buildDetailRow("EMD Payment Mode",
                _capitalize(widget.data['EMD_payment_mode'])),
            _buildDetailRow(
                "EMD Payment Date", widget.data['EMD_payment_date']),
            if (!isPaymentModeOffline)
              _buildDetailRow(
                  "Transaction Number", widget.data['transaction_number']),
            _buildDetailRow("Tender Status",
                _formatTenderStatus(widget.data['tender_status'])),
            if (!isApplied) ...[
              _buildDetailRow("Forfeiture Status",
                  _formatBool(widget.data['forfeiture_status'])),
              if (!isForfeitureStatusNo)
                _buildDetailRow(
                    "Forfeiture Reason", widget.data['forfeiture_reason']),
              _buildDetailRow("EMD Refund Status",
                  _formatBool(widget.data['EMD_refund_status'])),
              if (!isRefundStatusNo)
                _buildDetailRow(
                    "EMD Refund Date", widget.data['EMD_refund_date']),
              _buildDetailRow(
                  "Bid Outcome", _capitalize(widget.data['bid_outcome'])),
            ],
            const SizedBox(height: 20),
            if (widget.data['tender_attachments'] != null)
              ElevatedButton.icon(
                onPressed: () {
                  // Remove '/api' from baseurl for the PDF URL
                  final baseUrlWithoutApi = baseurl.replaceAll('/api', '');
                  final pdfUrl =
                      baseUrlWithoutApi + widget.data['tender_attachments'];
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PDFViwerScreen(url: pdfUrl)));
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("View Tender Attachment"),
              ),
            const SizedBox(height: 10),
            if (!isPaymentModeOffline &&
                widget.data['payment_attachments'] != null)
              ElevatedButton.icon(
                onPressed: () {
                  // Remove '/api' from baseurl for the PDF URL
                  final baseUrlWithoutApi = baseurl.replaceAll('/api', '');
                  final pdfUrl =
                      baseUrlWithoutApi + widget.data['payment_attachments'];
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PDFViwerScreen(url: pdfUrl)));
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("View Payment Attachment"),
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
                        builder: (context) => TenderEditForm(data: widget.data),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  mini: true,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.edit),
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
                  onPressed:
                      _showDeleteConfirmationDialog, // Call the delete dialog
                  backgroundColor: Colors.red,
                  mini: true,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.delete),
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
            ),
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
}
