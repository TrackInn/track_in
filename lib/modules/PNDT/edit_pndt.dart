import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:track_in/baseurl.dart';
import 'dart:io';

class EditPNDTLicenseScreen extends StatefulWidget {
  final Map data;

  const EditPNDTLicenseScreen({super.key, required this.data});

  @override
  _EditPNDTLicenseScreenState createState() => _EditPNDTLicenseScreenState();
}

class _EditPNDTLicenseScreenState extends State<EditPNDTLicenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for date fields
  final TextEditingController _submissionDateController =
      TextEditingController();
  final TextEditingController _approvalDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  String? productType;
  String? state;
  String? classOfDevice;
  bool software = false;
  DateTime? submissionDate;
  DateTime? approvalDate;
  DateTime? expiryDate;
  String? applicationNumber;
  String? licenseNumber;
  String? productName;
  String? modelNumber;
  String? intendedUse;
  String? legalManufacturer;
  String? authorizeAgentAddress;
  PlatformFile? attachment;

  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    // Initialize form fields with data from the widget
    applicationNumber = widget.data['application_number']?.toString();
    licenseNumber = widget.data['license_number']?.toString();
    submissionDate = DateTime.parse(widget.data['submission_date']);
    approvalDate = DateTime.parse(widget.data['approval_date']);
    expiryDate = DateTime.parse(widget.data['expiry_date']);
    productType = widget.data['product_type']?.toString();
    productName = widget.data['product_name']?.toString();
    modelNumber = widget.data['model_number']?.toString();
    state = widget.data['state']?.toString();
    intendedUse = widget.data['intended_use']?.toString();
    classOfDevice = widget.data['class_of_device']?.toString();
    software = widget.data['software'] ?? false;
    legalManufacturer = widget.data['legal_manufacturer']?.toString();
    authorizeAgentAddress = widget.data['authorize_agent_address']?.toString();

    // Set date controller values
    _submissionDateController.text =
        DateFormat('yyyy-MM-dd').format(submissionDate!);
    _approvalDateController.text =
        DateFormat('yyyy-MM-dd').format(approvalDate!);
    _expiryDateController.text = DateFormat('yyyy-MM-dd').format(expiryDate!);

    // Debugging: Print initial data
    print("Initial Data: ${widget.data}");
  }

  Future<void> submitPNDTForm(
      Map<String, dynamic> formData, File? attachment) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    String apiUrl = "$baseurl/updatepndtlicense/"; // Use the PATCH endpoint

    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(apiUrl));

      // Add the license number to the form data
      request.fields['license_number'] = licenseNumber!;

      // Format dates to 'YYYY-MM-DD'
      if (formData['submission_date'] != null) {
        formData['submission_date'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(formData['submission_date']));
      }
      if (formData['approval_date'] != null) {
        formData['approval_date'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(formData['approval_date']));
      }
      if (formData['expiry_date'] != null) {
        formData['expiry_date'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(formData['expiry_date']));
      }

      // Add form fields
      formData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add file (if exists)
      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachments', // Match this name with Django's serializer field
          attachment.path,
        ));
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 200) {
        print("PNDT License updated successfully!");
        Navigator.pop(context); // Go back to the previous screen
      } else {
        print("Failed to update PNDT License: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit PNDT License"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                        sectionTitle("Application Details"),
                        buildDisabledTextField(
                            "Application Number", applicationNumber ?? ''),
                        buildDisabledTextField(
                            "License Number", licenseNumber ?? ''),
                        buildDateField(
                            "Submission Date",
                            (value) => submissionDate = value,
                            _submissionDateController),
                        buildDateField(
                            "Approval Date",
                            (value) => approvalDate = value,
                            _approvalDateController),
                        buildDisabledTextField("Expiry Date",
                            DateFormat('yyyy-MM-dd').format(expiryDate!)),
                        const Divider(),
                        sectionTitle("Product Information"),
                        buildTextField("Product Type",
                            initialValue: productType,
                            onSaved: (value) => productType = value),
                        buildTextField("Product Name",
                            initialValue: productName,
                            onSaved: (value) => productName = value),
                        buildTextField("Model Number",
                            initialValue: modelNumber,
                            onSaved: (value) => modelNumber = value),
                        buildDisabledTextField("State", state ?? ''),
                        buildTextField("Intended Use",
                            initialValue: intendedUse,
                            onSaved: (value) => intendedUse = value),
                        buildDropdownField(
                            "Class of Device",
                            ['A', 'B', 'C', 'D'],
                            (value) => classOfDevice = value,
                            initialValue: classOfDevice),
                        SwitchListTile(
                          title: const Text("Contains Software"),
                          value: software,
                          onChanged: (bool value) {
                            setState(() {
                              software = value;
                            });
                          },
                        ),
                        const Divider(),
                        sectionTitle("Additional Details"),
                        buildTextField("Legal Manufacturer",
                            initialValue: legalManufacturer,
                            onSaved: (value) => legalManufacturer = value),
                        buildTextField("Authorized Agent Address",
                            initialValue: authorizeAgentAddress,
                            onSaved: (value) => authorizeAgentAddress = value),
                        buildFileUploadField("Attachments"),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      Map<String, dynamic> formData = {
                                        "application_number": applicationNumber,
                                        "license_number": licenseNumber,
                                        "submission_date":
                                            submissionDate?.toIso8601String(),
                                        "approval_date":
                                            approvalDate?.toIso8601String(),
                                        "expiry_date":
                                            expiryDate?.toIso8601String(),
                                        "product_type": productType,
                                        "product_name": productName,
                                        "model_number": modelNumber,
                                        "state": state,
                                        "intended_use": intendedUse,
                                        "class_of_device": classOfDevice,
                                        "software": software,
                                        "legal_manufacturer": legalManufacturer,
                                        "authorize_agent_address":
                                            authorizeAgentAddress,
                                      };
                                      print("Form Data to Submit: $formData");
                                      submitPNDTForm(
                                          formData, File(attachment!.path!));
                                    }
                                  },
                            child: const Text("Save",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget buildTextField(String label,
      {String? initialValue, Function(String?)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        enabled: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget buildDisabledTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDropdownField(
      String label, List<String> options, Function(String?) onChanged,
      {String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildDateField(String label, Function(DateTime?) onDateSelected,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            onDateSelected(pickedDate);
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }

  Widget buildFileUploadField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            onPressed: pickAndUploadFile,
          ),
          if (attachment != null)
            Text(
              attachment!.name,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Future<void> pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        attachment = result.files.single;
      });
    } else {
      print("No file selected.");
    }
  }
}
