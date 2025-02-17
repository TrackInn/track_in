import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

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

  String? tenderId;
  String? tenderTitle;
  String? issuingAuthority;
  String? tenderDescription;
  File? tenderAttachment;
  String? EMDAmount;
  bool EMDPaymentStatus = false;
  String? EMDPaymentMode;
  DateTime? EMDPaymentDate;
  String? transactionNumber;
  File? paymentAttachment;
  bool forfeitureStatus = false;
  String? forfeitureReason;
  bool EMDRefundStatus = false;
  DateTime? EMDRefundDate;
  String? bidAmount;
  bool bidOutcome = false;

  Future<void> submitTenderForm() async {
    String apiUrl = "your_api_url_here/tender/";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['tender_id'] = tenderId ?? "";
      request.fields['tender_title'] = tenderTitle ?? "";
      request.fields['issuing_authority'] = issuingAuthority ?? "";
      request.fields['tender_description'] = tenderDescription ?? "";
      request.fields['EMD_amount'] = EMDAmount ?? "";
      request.fields['EMD_payment_status'] = EMDPaymentStatus.toString();
      request.fields['EMD_payment_mode'] = EMDPaymentMode ?? "";
      request.fields['EMD_payment_date'] =
          EMDPaymentDate?.toIso8601String() ?? "";
      request.fields['transaction_number'] = transactionNumber ?? "";
      request.fields['forfeiture_status'] = forfeitureStatus.toString();
      request.fields['forfeiture_reason'] = forfeitureReason ?? "";
      request.fields['EMD_refund_status'] = EMDRefundStatus.toString();
      request.fields['EMD_refund_date'] =
          EMDRefundDate?.toIso8601String() ?? "";
      request.fields['bid_amount'] = bidAmount ?? "";
      request.fields['bid_outcome'] = bidOutcome.toString();

      if (tenderAttachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'tender_attachments', tenderAttachment!.path));
      }
      if (paymentAttachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'payment_attachments', paymentAttachment!.path));
      }

      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tender submitted successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit: ${response.body}")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    }
  }

  Widget buildTextField(String label,
      {bool isNumber = false, Function(String?)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onSaved: onSaved,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((String value) =>
                DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller,
      Function(DateTime?) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
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
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget buildRadioButtonField(
      String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: value,
                onChanged: onChanged,
              ),
              Text("Yes"),
              Radio<bool>(
                value: false,
                groupValue: value,
                onChanged: onChanged,
              ),
              Text("No"),
            ],
          ),
        ],
      ),
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
          backgroundColor: Colors.deepPurple,
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
        title: const Text("Tender Form"),
        backgroundColor: Colors.deepPurple,
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
                  buildTextField("Tender ID",
                      onSaved: (value) => tenderId = value),
                  buildTextField("Tender Title",
                      onSaved: (value) => tenderTitle = value),
                  buildTextField("Issuing Authority",
                      onSaved: (value) => issuingAuthority = value),
                  buildTextField("Tender Description",
                      onSaved: (value) => tenderDescription = value),
                  buildTextField("EMD Amount",
                      isNumber: true, onSaved: (value) => EMDAmount = value),
                  buildDropdownField("EMD Payment Mode", ["Online", "Offline"],
                      (value) => EMDPaymentMode = value),
                  buildDateField("EMD Payment Date", _EMDPaymentDateController,
                      (date) => EMDPaymentDate = date),
                  buildTextField("Transaction Number",
                      onSaved: (value) => transactionNumber = value),
                  buildRadioButtonField("Forfeiture Status", forfeitureStatus,
                      (value) {
                    setState(() {
                      forfeitureStatus = value!;
                    });
                  }),
                  buildTextField("Forfeiture Reason",
                      onSaved: (value) => forfeitureReason = value),
                  buildRadioButtonField("EMD Refund Status", EMDRefundStatus,
                      (value) {
                    setState(() {
                      EMDRefundStatus = value!;
                    });
                  }),
                  buildDateField("EMD Refund Date", _EMDRefundDateController,
                      (date) => EMDRefundDate = date),
                  buildTextField("Bid Amount",
                      isNumber: true, onSaved: (value) => bidAmount = value),
                  buildRadioButtonField("Bid Outcome", bidOutcome, (value) {
                    setState(() {
                      bidOutcome = value!;
                    });
                  }),
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
