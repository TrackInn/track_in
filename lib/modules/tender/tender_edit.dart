import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:track_in/baseurl.dart'; // Import the base URL
import 'dart:convert'; // For JSON parsing

class TenderEditForm extends StatefulWidget {
  final Map<String, dynamic> data; // Accept data instead of tenderId

  const TenderEditForm({super.key, required this.data});

  @override
  _TenderEditFormState createState() => _TenderEditFormState();
}

class _TenderEditFormState extends State<TenderEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _EMDPaymentDateController =
      TextEditingController();
  final TextEditingController _EMDRefundDateController =
      TextEditingController();

  // Fields in the same order as the backend model
  String? tenderId;
  String? tenderTitle;
  String? issuingAuthority;
  String? tenderHandler; // Will be populated from the dropdown
  String? tenderDescription;
  File? tenderAttachment;
  String? EMDAmount;
  String? EMDPaymentMode;
  DateTime? EMDPaymentDate;
  String? transactionNumber;
  File? paymentAttachment;
  String? tenderStatus = "applied"; // Default to "applied"
  bool forfeitureStatus = false;
  String? forfeitureReason;
  bool EMDRefundStatus = false;
  DateTime? EMDRefundDate;
  String? bidOutcome = "not_declared"; // Default to "not_declared"

  // List to store profiles for the dropdown
  List<Map<String, dynamic>> profiles = [];
  bool isLoadingProfiles = true; // To track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize fields with data from the passed-in map
    tenderId = widget.data['tender_id'];
    tenderTitle = widget.data['tender_title'];
    issuingAuthority = widget.data['issuing_authority'];
    tenderHandler = widget.data['tender_handler'];
    tenderDescription = widget.data['tender_description'];
    EMDAmount = widget.data['EMD_amount'];
    EMDPaymentMode = widget.data['EMD_payment_mode'];
    EMDPaymentDate = widget.data['EMD_payment_date'] != null
        ? DateFormat('yyyy-MM-dd').parse(widget.data['EMD_payment_date'])
        : null;
    transactionNumber = widget.data['transaction_number'];
    tenderStatus = widget.data['tender_status'];
    forfeitureStatus = widget.data['forfeiture_status'];
    forfeitureReason = widget.data['forfeiture_reason'];
    EMDRefundStatus = widget.data['EMD_refund_status'];
    EMDRefundDate = widget.data['EMD_refund_date'] != null
        ? DateFormat('yyyy-MM-dd').parse(widget.data['EMD_refund_date'])
        : null;
    bidOutcome = widget.data['bid_outcome'];

    // Initialize date controllers
    if (EMDPaymentDate != null) {
      _EMDPaymentDateController.text =
          DateFormat('yyyy-MM-dd').format(EMDPaymentDate!);
    }
    if (EMDRefundDate != null) {
      _EMDRefundDateController.text =
          DateFormat('yyyy-MM-dd').format(EMDRefundDate!);
    }

    // Fetch profiles when the widget initializes
    fetchProfiles();
  }

  // Fetch profiles with the role 'tender_viewer'
  Future<void> fetchProfiles() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseurl/list-users/?role=tender_viewer'), // Use the existing API
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profiles = List<Map<String, dynamic>>.from(data);
          isLoadingProfiles = false;
        });
      } else {
        throw Exception('Failed to load profiles');
      }
    } catch (error) {
      setState(() {
        isLoadingProfiles = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profiles: $error')),
      );
    }
  }

  // Helper function to check if fields below tender status should be enabled
  bool get _areFieldsBelowTenderStatusEnabled {
    return tenderStatus == "completed";
  }

  // Update tender details on the server
  Future<void> _updateTenderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var request =
          http.MultipartRequest('PATCH', Uri.parse('$baseurl/updatetender/'));
      request.fields['tender_id'] = tenderId ?? "";
      request.fields['tender_title'] = tenderTitle ?? "";
      request.fields['issuing_authority'] = issuingAuthority ?? "";
      request.fields['tender_handler'] = tenderHandler ?? "";
      request.fields['tender_description'] = tenderDescription ?? "";
      request.fields['EMD_amount'] = EMDAmount ?? "";
      request.fields['EMD_payment_mode'] = EMDPaymentMode ?? "";
      request.fields['EMD_payment_date'] = EMDPaymentDate != null
          ? DateFormat('yyyy-MM-dd').format(EMDPaymentDate!)
          : "";
      request.fields['transaction_number'] = transactionNumber ?? "";
      request.fields['tender_status'] = tenderStatus ?? "applied";
      request.fields['forfeiture_status'] = forfeitureStatus.toString();
      request.fields['forfeiture_reason'] = forfeitureReason ?? "";
      request.fields['EMD_refund_status'] = EMDRefundStatus.toString();
      request.fields['EMD_refund_date'] = EMDRefundDate != null
          ? DateFormat('yyyy-MM-dd').format(EMDRefundDate!)
          : "";
      request.fields['bid_outcome'] = bidOutcome ?? "not_declared";

      // Add file attachments
      if (tenderAttachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'tender_attachments',
          tenderAttachment!.path,
        ));
      }
      if (paymentAttachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'payment_attachments',
          paymentAttachment!.path,
        ));
      }

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tender updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: ${response.body}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to pick tender attachment
  Future<void> pickTenderAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        tenderAttachment = File(result.files.single.path!);
      });
    }
  }

  // Helper method to pick payment attachment
  Future<void> pickPaymentAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        paymentAttachment = File(result.files.single.path!);
      });
    }
  }

  // Helper method to build a text field
  Widget buildTextField(String label,
      {bool isNumber = false,
      Function(String?)? onSaved,
      bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        initialValue: enabled ? _getInitialValue(label) : null,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onSaved: onSaved,
        enabled: enabled,
        validator: enabled
            ? (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null
            : null,
      ),
    );
  }

  // Helper method to build a disabled text field
  Widget buildDisabledTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: value,
        enabled: false, // Disable editing
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Helper method to get initial value for text fields
  String? _getInitialValue(String label) {
    switch (label) {
      case "Tender ID":
        return tenderId;
      case "Tender Title":
        return tenderTitle;
      case "Issuing Authority":
        return issuingAuthority;
      case "Tender Handler":
        return tenderHandler;
      case "Tender Description":
        return tenderDescription;
      case "EMD Amount":
        return EMDAmount;
      case "Transaction Number":
        return transactionNumber;
      case "Forfeiture Reason":
        return forfeitureReason;
      default:
        return null;
    }
  }

  // Helper method to build a dropdown field
  Widget buildDropdownField(
      String label, List<String> items, Function(String?) onChanged,
      {bool enabled = true, bool isMandatory = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: _getDropdownValue(label, items),
        items: items.map((String value) {
          String displayText;
          switch (value) {
            case "not_declared":
              displayText = "Not declared";
              break;
            case "won":
              displayText = "Won";
              break;
            case "lost":
              displayText = "Lost";
              break;
            default:
              displayText = value;
          }
          return DropdownMenuItem(
            value: value,
            child: Text(displayText),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        validator: enabled && isMandatory
            ? (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null
            : null,
      ),
    );
  }

  // Helper method to get initial value for dropdown fields
  String? _getDropdownValue(String label, List<String> items) {
    switch (label) {
      case "EMD Payment Mode":
        return EMDPaymentMode;
      case "Tender Status":
        return tenderStatus;
      case "Bid Outcome":
        return bidOutcome;
      default:
        return items.contains(bidOutcome) ? bidOutcome : null;
    }
  }

  // Helper method to build a profile dropdown
  Widget buildProfileDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Tender Handler",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: tenderHandler,
        items: profiles.map((profile) {
          return DropdownMenuItem(
            value: profile['profile']['id']
                .toString(), // Use the profile ID as the value
            child: Text(
                profile['profile']['username']), // Display the profile username
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            tenderHandler = value; // Update the selected profile
          });
        },
        validator: (value) => value == null || value.isEmpty
            ? 'Please select a tender handler'
            : null,
      ),
    );
  }

  // Helper method to build a date field
  Widget buildDateField(String label, TextEditingController controller,
      Function(DateTime?) onDateSelected,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: enabled
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  onDateSelected(pickedDate);
                }
              }
            : null,
        validator: enabled
            ? (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null
            : null,
      ),
    );
  }

  // Helper method to build a radio button field
  Widget buildRadioButtonField(
      String label, bool value, Function(bool?) onChanged,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: value,
                onChanged: enabled ? onChanged : null,
              ),
              const Text("Yes"),
              Radio<bool>(
                value: false,
                groupValue: value,
                onChanged: enabled ? onChanged : null,
              ),
              const Text("No"),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build a file picker button
  Widget buildFilePickerButton(String label, File? file, Function() onPressed,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: Text("Upload $label"),
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Selected: ${file.path.split('/').last}"),
          ),
      ],
    );
  }

  // Helper method to build a submit button
  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blue,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _updateTenderDetails();
          }
        },
        child: const Text("Submit",
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fields in the same order as the backend model
                        buildDisabledTextField("Tender ID", tenderId ?? ''),
                        buildDisabledTextField(
                            "Tender Title", tenderTitle ?? ''),
                        buildDisabledTextField(
                            "Issuing Authority", issuingAuthority ?? ''),
                        isLoadingProfiles
                            ? const CircularProgressIndicator()
                            : buildProfileDropdown(), // Profile dropdown
                        buildTextField("Tender Description",
                            onSaved: (value) => tenderDescription = value),
                        buildFilePickerButton("Tender Attachment",
                            tenderAttachment, pickTenderAttachment),
                        buildTextField("EMD Amount",
                            isNumber: true,
                            onSaved: (value) => EMDAmount = value),
                        buildDropdownField(
                            "EMD Payment Mode",
                            ["online", "offline"],
                            (value) => EMDPaymentMode = value),
                        buildDateField(
                            "EMD Payment Date",
                            _EMDPaymentDateController,
                            (date) => EMDPaymentDate = date),
                        buildTextField("Transaction Number",
                            onSaved: (value) => transactionNumber = value),
                        buildFilePickerButton("Payment Attachment",
                            paymentAttachment, pickPaymentAttachment),
                        buildDropdownField(
                            "Tender Status", ["applied", "completed"], (value) {
                          setState(() {
                            tenderStatus = value;
                            if (value == "completed") {
                              // Reset bidOutcome to a valid value when status is changed to "completed"
                              bidOutcome = "won"; // Default to "won" or "lost"
                            } else {
                              bidOutcome =
                                  "not_declared"; // Reset to default for "applied"
                            }
                          });
                        }),
                        buildRadioButtonField(
                            "Forfeiture Status", forfeitureStatus, (value) {
                          setState(() {
                            forfeitureStatus = value!;
                          });
                        }, enabled: _areFieldsBelowTenderStatusEnabled),
                        if (forfeitureStatus)
                          buildTextField("Forfeiture Reason",
                              onSaved: (value) => forfeitureReason = value,
                              enabled: _areFieldsBelowTenderStatusEnabled),
                        buildRadioButtonField(
                            "EMD Refund Status", EMDRefundStatus, (value) {
                          setState(() {
                            EMDRefundStatus = value!;
                          });
                        }, enabled: _areFieldsBelowTenderStatusEnabled),
                        if (EMDRefundStatus)
                          buildDateField(
                              "EMD Refund Date",
                              _EMDRefundDateController,
                              (date) => EMDRefundDate = date,
                              enabled: _areFieldsBelowTenderStatusEnabled),
                        buildDropdownField(
                          "Bid Outcome",
                          tenderStatus == "completed"
                              ? ["won", "lost"]
                              : ["not_declared"],
                          (value) {
                            setState(() {
                              bidOutcome = value;
                            });
                          },
                          enabled: _areFieldsBelowTenderStatusEnabled,
                          isMandatory: tenderStatus == "completed",
                        ),
                        const SizedBox(height: 20),
                        buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
