import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:track_in/baseurl.dart';
import 'dart:io';

class LicenseForm extends StatefulWidget {
  const LicenseForm({super.key});

  @override
  _LicenseFormState createState() => _LicenseFormState();
}

class _LicenseFormState extends State<LicenseForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for date fields
  final TextEditingController _submissionDateController =
      TextEditingController();
  final TextEditingController _approvalDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  String? applicationType;
  String? productType;
  String? classOfDeviceType;
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
  String? agentAddress;
  String? accessories;
  String? shelfLife;
  String? packSize;
  PlatformFile? attachment;

  Future<void> submitLicenseForm(
      Map<String, dynamic> formData, File? attachment) async {
    String apiUrl = "$baseurl/license/";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Format dates to 'YYYY-MM-DD'
      if (formData['date_of_submission'] != null) {
        formData['date_of_submission'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(formData['date_of_submission']));
      }
      if (formData['date_of_approval'] != null) {
        formData['date_of_approval'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(formData['date_of_approval']));
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
      if (response.statusCode == 201) {
        print("License submitted successfully!");
      } else {
        print("Failed to submit license: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
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
                  sectionTitle("Application Details"),
                  buildDropdownField(
                      "Application Type",
                      [
                        'manufacturing_license',
                        'test_license',
                        'import_license',
                        'export_license'
                      ],
                      (value) => applicationType = value),
                  buildTextField("Application Number",
                      onSaved: (value) => applicationNumber = value),
                  buildTextField("License Number",
                      onSaved: (value) => licenseNumber = value),
                  buildDateField(
                      "Date of Submission",
                      (value) => submissionDate = value,
                      _submissionDateController),
                  buildDateField("Date of Approval",
                      (value) => approvalDate = value, _approvalDateController),
                  buildDateField("Expiry Date", (value) => expiryDate = value,
                      _expiryDateController),
                  const Divider(),
                  sectionTitle("Product Information"),
                  buildDropdownField(
                      "Product Type",
                      ['choice1', 'choice2', 'choice3', 'choice4'],
                      (value) => productType = value),
                  buildTextField("Product Name",
                      onSaved: (value) => productName = value),
                  buildTextField("Model Number",
                      onSaved: (value) => modelNumber = value),
                  buildTextField("Intended Use",
                      onSaved: (value) => intendedUse = value),
                  buildDropdownField(
                      "Class of Device Type",
                      ['choice1', 'choice2', 'choice3', 'choice4'],
                      (value) => classOfDeviceType = value),
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
                      onSaved: (value) => legalManufacturer = value),
                  buildTextField("Agent Address",
                      onSaved: (value) => agentAddress = value),
                  buildTextField("Accessories",
                      onSaved: (value) => accessories = value),
                  buildTextField("Shelf Life",
                      onSaved: (value) => shelfLife = value),
                  buildTextField("Pack Size",
                      isNumber: true, onSaved: (value) => packSize = value),
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Map<String, dynamic> formData = {
                            "application_type": applicationType,
                            "application_number": applicationNumber,
                            "license_number": licenseNumber,
                            "date_of_submission":
                                submissionDate?.toIso8601String(),
                            "date_of_approval": approvalDate?.toIso8601String(),
                            "expiry_date": expiryDate?.toIso8601String(),
                            "product_type": productType,
                            "product_name": productName,
                            "model_number": modelNumber,
                            "intended_use": intendedUse,
                            "class_of_device_type": classOfDeviceType,
                            "software": software,
                            "legal_manufacturer": legalManufacturer,
                            "agent_address": agentAddress,
                            "accesories": accessories,
                            "shell_life": shelfLife,
                            "pack_size": packSize,
                          };
                          print(formData);
                          submitLicenseForm(formData, File(attachment!.path!));
                        }
                      },
                      child: const Text("Submit",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
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
      {bool isNumber = false, Function(String?)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  Widget buildDropdownField(
      String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
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
    // Pick a file
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
