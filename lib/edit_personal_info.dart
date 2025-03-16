import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_in/baseurl.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  @override
  _EditPersonalInfoScreenState createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  // Controllers for text fields
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPersonalDetails();
  }

  // Fetch existing personal details
  Future<void> _fetchPersonalDetails() async {
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

    final url = Uri.parse('$baseurl/editpersonaldetails/$profileId/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _dateOfBirthController.text = responseData['date_of_birth'] ?? '';
          _genderController.text = responseData['gender'] ?? '';
          _nationalityController.text = responseData['nationality'] ?? '';
          _bloodGroupController.text = responseData['blood_group'] ?? '';
        });
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Personal details not found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch personal details')),
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

  // Update personal details
  Future<void> _updatePersonalDetails() async {
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

      final url = Uri.parse('$baseurl/editpersonaldetails/');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        "profile_id": profileId,
        "date_of_birth": _dateOfBirthController.text,
        "gender": _genderController.text,
        "nationality": _nationalityController.text,
        "blood_group": _bloodGroupController.text,
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
              content: Text('Personal details updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Navigate back after saving
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['msg'] ??
                    'Failed to update personal details')),
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
          "Edit Personal Information",
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date of Birth Field
                    TextFormField(
                      controller: _dateOfBirthController,
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        hintText: "YYYY-MM-DD", // Placeholder for date format
                        prefixIcon:
                            Icon(Icons.calendar_today, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType:
                          TextInputType.datetime, // Suggest date input
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your date of birth";
                        }
                        // Optional: Add regex validation for date format
                        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                          return "Please enter the date in YYYY-MM-DD format";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Gender Field
                    TextFormField(
                      controller: _genderController,
                      decoration: InputDecoration(
                        labelText: "Gender",
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your gender";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Nationality Field
                    TextFormField(
                      controller: _nationalityController,
                      decoration: InputDecoration(
                        labelText: "Nationality",
                        prefixIcon: Icon(Icons.public, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your nationality";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Blood Group Field
                    TextFormField(
                      controller: _bloodGroupController,
                      decoration: InputDecoration(
                        labelText: "Blood Group",
                        prefixIcon: Icon(Icons.bloodtype, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your blood group";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePersonalDetails,
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

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }
}
