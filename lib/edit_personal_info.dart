import 'package:flutter/material.dart';

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
      body: Padding(
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
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your date of birth";
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save logic here
                      print("Date of Birth: ${_dateOfBirthController.text}");
                      print("Gender: ${_genderController.text}");
                      print("Nationality: ${_nationalityController.text}");
                      print("Blood Group: ${_bloodGroupController.text}");

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Personal information saved successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigate back after saving
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
