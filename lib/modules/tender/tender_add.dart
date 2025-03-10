import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:track_in/baseurl.dart'; // Import the base URL

class TenderForm extends StatefulWidget {
  const TenderForm({super.key});

  @override
  _TenderFormState createState() => _TenderFormState();
}

class _TenderFormState extends State<TenderForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _EMDPaymentDateController =
      TextEditingController();
  final TextEditingController _EMDRefundDateController =
      TextEditingController();

  // Fields in the same order as the backend model
  String? tenderId;
  String? tenderTitle;
  String? issuingAuthority;
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

  // Helper function to check if fields below tender status should be enabled
  bool get _areFieldsBelowTenderStatusEnabled {
    return tenderStatus == "completed";
  }

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

  Future<void> submitTenderForm() async {
    String apiUrl =
        "$baseurl/addtenderdetails/"; // Use the base URL and endpoint

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add fields in the same order as the backend model
      request.fields['tender_id'] = tenderId ?? "";
      request.fields['tender_title'] = tenderTitle ?? "";
      request.fields['issuing_authority'] = issuingAuthority ?? "";
      request.fields['tender_description'] = tenderDescription ?? "";
      request.fields['tender_attachments'] = tenderAttachment != null
          ? tenderAttachment!.path
          : ""; // File path for attachment
      request.fields['EMD_amount'] = EMDAmount ?? "";
      request.fields['EMD_payment_mode'] = EMDPaymentMode ?? "";
      request.fields['EMD_payment_date'] = EMDPaymentDate != null
          ? DateFormat('yyyy-MM-dd').format(EMDPaymentDate!)
          : "";
      request.fields['transaction_number'] = transactionNumber ?? "";
      request.fields['payment_attachments'] = paymentAttachment != null
          ? paymentAttachment!.path
          : ""; // File path for attachment
      request.fields['tender_status'] = tenderStatus ?? "applied";
      request.fields['forfeiture_status'] = forfeitureStatus.toString();
      request.fields['forfeiture_reason'] = forfeitureReason ?? "";
      request.fields['EMD_refund_status'] = EMDRefundStatus.toString();
      request.fields['EMD_refund_date'] = EMDRefundDate != null
          ? DateFormat('yyyy-MM-dd').format(EMDRefundDate!)
          : "";
      request.fields['bid_outcome'] =
          bidOutcome ?? "not_declared"; // Ensure bid_outcome is included

      // Add file attachments
      if (tenderAttachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'tender_attachments', // Field name must match the model
          tenderAttachment!.path,
        ));
      }
      if (paymentAttachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'payment_attachments', // Field name must match the model
          paymentAttachment!.path,
        ));
      }

      // Debugging: Print the bid_outcome value before submission
      print("Submitting bid_outcome: $bidOutcome");

      // Send the request
      var response = await http.Response.fromStream(await request.send());

      // Handle the response
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tender submitted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: ${response.body}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onSaved: onSaved,
        enabled: enabled, // Control enable/disable state
        validator: enabled
            ? (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null
            : null, // Make field mandatory only if enabled
      ),
    );
  }

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
        value: items.contains(bidOutcome)
            ? bidOutcome
            : null, // Ensure value exists in items
        items: items.map((String value) {
          // Map backend values to UI-friendly labels
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
        onChanged: enabled ? onChanged : null, // Control enable/disable state
        validator: enabled && isMandatory
            ? (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null
            : null, // Make field mandatory only if enabled and isMandatory is true
      ),
    );
  }

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
                  controller.text = DateFormat('yyyy-MM-dd')
                      .format(pickedDate); // Format date
                  onDateSelected(pickedDate); // Save the selected date
                }
              }
            : null, // Control enable/disable state
        validator: enabled
            ? (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null
            : null, // Make field mandatory only if enabled
      ),
    );
  }

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
                onChanged:
                    enabled ? onChanged : null, // Control enable/disable state
              ),
              const Text("Yes"),
              Radio<bool>(
                value: false,
                groupValue: value,
                onChanged:
                    enabled ? onChanged : null, // Control enable/disable state
              ),
              const Text("No"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFilePickerButton(String label, File? file, Function() onPressed,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: enabled ? onPressed : null, // Control enable/disable state
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
            submitTenderForm();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fields in the same order as the backend model
                  buildTextField("Tender ID",
                      onSaved: (value) => tenderId = value),
                  buildTextField("Tender Title",
                      onSaved: (value) => tenderTitle = value),
                  buildTextField("Issuing Authority",
                      onSaved: (value) => issuingAuthority = value),
                  buildTextField("Tender Description",
                      onSaved: (value) => tenderDescription = value),
                  buildFilePickerButton("Tender Attachment", tenderAttachment,
                      pickTenderAttachment),
                  buildTextField("EMD Amount",
                      isNumber: true, onSaved: (value) => EMDAmount = value),
                  buildDropdownField("EMD Payment Mode", ["online", "offline"],
                      (value) => EMDPaymentMode = value),
                  buildDateField("EMD Payment Date", _EMDPaymentDateController,
                      (date) => EMDPaymentDate = date),
                  buildTextField("Transaction Number",
                      onSaved: (value) => transactionNumber = value),
                  buildFilePickerButton("Payment Attachment", paymentAttachment,
                      pickPaymentAttachment),
                  buildDropdownField("Tender Status", ["applied", "completed"],
                      (value) {
                    setState(() {
                      tenderStatus = value;
                      // Reset bid_outcome to "not_declared" if tender_status is "applied"
                      if (value == "applied") {
                        bidOutcome = "not_declared";
                      }
                    });
                  }),
                  buildRadioButtonField("Forfeiture Status", forfeitureStatus,
                      (value) {
                    setState(() {
                      forfeitureStatus = value!;
                    });
                  }, enabled: _areFieldsBelowTenderStatusEnabled),
                  if (forfeitureStatus)
                    buildTextField("Forfeiture Reason",
                        onSaved: (value) => forfeitureReason = value,
                        enabled: _areFieldsBelowTenderStatusEnabled),
                  buildRadioButtonField("EMD Refund Status", EMDRefundStatus,
                      (value) {
                    setState(() {
                      EMDRefundStatus = value!;
                    });
                  }, enabled: _areFieldsBelowTenderStatusEnabled),
                  if (EMDRefundStatus)
                    buildDateField("EMD Refund Date", _EMDRefundDateController,
                        (date) => EMDRefundDate = date,
                        enabled: _areFieldsBelowTenderStatusEnabled),
                  buildDropdownField(
                    "Bid Outcome",
                    tenderStatus == "completed"
                        ? ["won", "lost"]
                        : ["not_declared"],
                    (value) {
                      setState(() {
                        bidOutcome = value; // Ensure bidOutcome is updated
                      });
                    },
                    enabled: _areFieldsBelowTenderStatusEnabled,
                    isMandatory: tenderStatus ==
                        "completed", // Make mandatory only if tender status is "completed"
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
