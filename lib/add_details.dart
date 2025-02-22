import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_in/baseurl.dart';

class AdditionalDetailsScreen extends StatefulWidget {
  const AdditionalDetailsScreen({super.key});

  @override
  _AdditionalDetailsScreenState createState() =>
      _AdditionalDetailsScreenState();
}

class _AdditionalDetailsScreenState extends State<AdditionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('$baseurl/changeaccountaddress/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'state': stateController.text,
          'district': districtController.text,
          'pincode': pincodeController.text,
          'phone': phoneController.text,
          'bio': bioController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Additional Details',
          style: TextStyle(color: Colors.white), // White text
        ),
        titleSpacing: 0, // Remove default spacing for the title
        backgroundColor: Colors.blue, // Background color remains blue
        leading: const IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: null, // No action on press
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(stateController, "State", Icons.location_on),
              _buildTextField(districtController, "District", Icons.map),
              _buildTextField(pincodeController, "Pincode", Icons.pin,
                  TextInputType.number),
              _buildTextField(
                  phoneController, "Phone", Icons.phone, TextInputType.phone),
              _buildTextField(
                  bioController, "Bio", Icons.person, TextInputType.text, 3),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitDetails,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue, // Changed to blue
                  ),
                  child: const Text("Save",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white)), // Text color set to white
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      [TextInputType keyboardType = TextInputType.text, int maxLines = 1]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon, color: Colors.blue), // Icon color changed to blue
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white, // Text box inside color set to white
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}
