import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:track_in/baseurl.dart';

class PNDTLicenseForm extends StatefulWidget {
  const PNDTLicenseForm({super.key});

  @override
  _PNDTLicenseFormState createState() => _PNDTLicenseFormState();
}

class _PNDTLicenseFormState extends State<PNDTLicenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _submissionDateController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _approvalDateController = TextEditingController();

  String? licenseNumber;
  String? applicationNumber;
  DateTime? submissionDate;
  DateTime? expiryDate;
  DateTime? approvalDate;
  String? productType;
  String? productName;
  String? modelNumber;
  String? state;
  String? intendedUse;
  String? classOfDevice;
  bool softwareUsed = false;
  String? legalManufacturer;
  String? authorizeAgentAddress;
  PlatformFile? attachment;
  bool _isLoading = false; // Track loading state

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Prepare the data to be sent to the API
        final Map<String, dynamic> formData = {
          'license_number': licenseNumber,
          'application_number': applicationNumber,
          'submission_date': submissionDate
              ?.toIso8601String()
              .split('T')[0], // Send only the date part
          'expiry_date': expiryDate
              ?.toIso8601String()
              .split('T')[0], // Send only the date part
          'approval_date': approvalDate
              ?.toIso8601String()
              .split('T')[0], // Send only the date part
          'product_type': productType,
          'product_name': productName,
          'model_number': modelNumber,
          'state': state,
          'intended_use': intendedUse,
          'class_of_device': classOfDevice,
          'software': softwareUsed, // Send as boolean
          'legal_manufacturer': legalManufacturer,
          'authorize_agent_address': authorizeAgentAddress,
        };

        // Create a multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseurl/addpndtlicense/'),
        );

        // Add form fields to the request
        request.fields.addAll(formData.map((key, value) {
          // Convert non-String values to String
          if (value is bool) {
            return MapEntry(key, value.toString()); // Convert bool to String
          } else {
            return MapEntry(key, value ?? '');
          }
        }));

        // Add the attachment file if it exists
        if (attachment != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'attachments',
            attachment!.path!,
          ));
        }

        // Send the request
        var response = await request.send();

        if (response.statusCode == 201) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form submitted successfully!')),
          );

          // Navigate back to the previous screen
          Navigator.pop(context);
        } else {
          // Error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to submit form. Status code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        attachment = result.files.first;
      });
    }
  }

  Widget _buildTextField(String label, {Function(String?)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSaved: onSaved,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
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

  Widget _buildDropdownField(
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

  Widget _buildToggleField(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attachments', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _pickAttachment,
            child: const Text('Choose File'),
          ),
          if (attachment != null) Text('Selected file: ${attachment!.name}'),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blue,
        ),
        onPressed:
            _isLoading ? null : _submitForm, // Disable button when loading
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white) // Show loading indicator
            : const Text(
                "Submit",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // This removes the default back button
        title: const Text(
          'Add PNDT License',
          style: TextStyle(color: Colors.white),
        ),
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
                  _buildTextField("License Number",
                      onSaved: (value) => licenseNumber = value),
                  _buildTextField("Application Number",
                      onSaved: (value) => applicationNumber = value),
                  _buildDateField("Submission Date", _submissionDateController,
                      (date) => submissionDate = date),
                  _buildDateField("Expiry Date", _expiryDateController,
                      (date) => expiryDate = date),
                  _buildDateField("Approval Date", _approvalDateController,
                      (date) => approvalDate = date),
                  _buildTextField("Product Type",
                      onSaved: (value) => productType = value),
                  _buildTextField("Product Name",
                      onSaved: (value) => productName = value),
                  _buildTextField("Model Number",
                      onSaved: (value) => modelNumber = value),
                  _buildDropdownField("State", [
                    'Andhra Pradesh',
                    'Arunachal Pradesh',
                    'Assam',
                    'Bihar',
                    'Chhattisgarh',
                    'Goa',
                    'Gujarat',
                    'Haryana',
                    'Himachal Pradesh',
                    'Jharkhand',
                    'Karnataka',
                    'Kerala',
                    'Madhya Pradesh',
                    'Maharashtra',
                    'Manipur',
                    'Meghalaya',
                    'Mizoram',
                    'Nagaland',
                    'Odisha',
                    'Punjab',
                    'Rajasthan',
                    'Sikkim',
                    'Tamil Nadu',
                    'Telangana',
                    'Tripura',
                    'Uttar Pradesh',
                    'Uttarakhand',
                    'West Bengal',
                    'Andaman and Nicobar Islands',
                    'Chandigarh',
                    'Dadra and Nagar Haveli and Daman and Diu',
                    'Delhi',
                    'Jammu and Kashmir',
                    'Ladakh',
                    'Lakshadweep',
                    'Puducherry'
                  ], (value) {
                    setState(() {
                      state = value;
                    });
                  }),
                  _buildTextField("Intended Use",
                      onSaved: (value) => intendedUse = value),
                  _buildDropdownField("Class of Device", ["A", "B", "C", "D"],
                      (value) {
                    setState(() {
                      classOfDevice = value;
                    });
                  }),
                  _buildToggleField("Software Used", softwareUsed, (value) {
                    setState(() {
                      softwareUsed = value;
                    });
                  }),
                  _buildTextField("Legal Manufacturer",
                      onSaved: (value) => legalManufacturer = value),
                  _buildTextField("Authorize Agent Address",
                      onSaved: (value) => authorizeAgentAddress = value),
                  _buildAttachmentField(),
                  const SizedBox(height: 20),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
