import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String? intendedUse;
  String? classOfDevice;
  String? softwareUsed;
  String? legalManufacturer;
  String? authorizeAgentAddress;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Submit the form data to your backend or API
      print("License Number: $licenseNumber");
      print("Application Number: $applicationNumber");
      print("Submission Date: $submissionDate");
      print("Expiry Date: $expiryDate");
      print("Approval Date: $approvalDate");
      print("Product Type: $productType");
      print("Product Name: $productName");
      print("Model Number: $modelNumber");
      print("Intended Use: $intendedUse");
      print("Class of Device: $classOfDevice");
      print("Software Used: $softwareUsed");
      print("Legal Manufacturer: $legalManufacturer");
      print("Authorize Agent Address: $authorizeAgentAddress");
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
        onPressed: _submitForm,
        child: const Text("Submit",
            style: TextStyle(fontSize: 18, color: Colors.white)),
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
                  _buildDropdownField("Product Type",
                      ["choice1", "choice2", "choice3", "choice4"], (value) {
                    setState(() {
                      productType = value;
                    });
                  }),
                  _buildTextField("Product Name",
                      onSaved: (value) => productName = value),
                  _buildTextField("Model Number",
                      onSaved: (value) => modelNumber = value),
                  _buildTextField("Intended Use",
                      onSaved: (value) => intendedUse = value),
                  _buildDropdownField("Class of Device",
                      ["class1", "class2", "class3", "ultrasonic"], (value) {
                    setState(() {
                      classOfDevice = value;
                    });
                  }),
                  _buildTextField("Software Used",
                      onSaved: (value) => softwareUsed = value),
                  _buildTextField("Legal Manufacturer",
                      onSaved: (value) => legalManufacturer = value),
                  _buildTextField("Authorize Agent Address",
                      onSaved: (value) => authorizeAgentAddress = value),
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
