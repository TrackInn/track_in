import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdditionalDetails();
  }

  Future<void> _fetchAdditionalDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = json.decode(prefs.getString('userDetails') ?? '{}');
    final profileId = userDetails['id'];

    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile ID not found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseurl/changeaccountaddress/$profileId/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          stateController.text = responseData['state'] ?? '';
          districtController.text = responseData['district'] ?? '';
          pincodeController.text = responseData['pincode'] ?? '';
          phoneController.text = responseData['phone'] ?? '';
          bioController.text = responseData['bio'] ?? '';
        });
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Additional details not found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch additional details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final userDetails = json.decode(prefs.getString('userDetails') ?? '{}');
      final profileId = userDetails['id'];

      if (profileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile ID not found')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final url = Uri.parse('$baseurl/changeaccountaddress/$profileId/');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        "state": stateController.text,
        "district": districtController.text,
        "pincode": pincodeController.text,
        "phone": phoneController.text,
        "bio": bioController.text,
      });

      try {
        final response = await http.patch(
          url,
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Additional details updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Navigate back after saving
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['msg'] ??
                    'Failed to update additional details')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Additional Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        stateController, "State", Icons.location_on),
                    SizedBox(height: 16),
                    _buildTextField(districtController, "District", Icons.map),
                    SizedBox(height: 16),
                    _buildTextField(pincodeController, "Pincode", Icons.pin,
                        TextInputType.number),
                    SizedBox(height: 16),
                    _buildTextField(phoneController, "Phone", Icons.phone,
                        TextInputType.phone),
                    SizedBox(height: 16),
                    _buildTextField(bioController, "Bio", Icons.person,
                        TextInputType.text, 3),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitDetails,
                        child: Text(
                          "Save",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      [TextInputType keyboardType = TextInputType.text, int maxLines = 1]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
