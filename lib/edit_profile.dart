import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:track_in/edit_personal_info.dart';
import 'package:track_in/add_details.dart';
import 'package:track_in/acc_info.dart';
import 'package:track_in/baseurl.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? personalDetails;
  Map<String, dynamic>? additionalDetails;
  String? profileImageUrl;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userDetails = json.decode(prefs.getString('userDetails') ?? '{}');
      personalDetails = json.decode(prefs.getString('personalDetails') ?? '{}');
      additionalDetails =
          json.decode(prefs.getString('additionalDetails') ?? '{}');
      profileImageUrl = prefs.getString('profileImage');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage(_imageFile!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = userDetails?['id']; // Get user ID from userDetails

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseurl/updateprofileimage/$userId/'),
      );

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send request
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        // Update local state with new image URL
        if (jsonResponse['image_url'] != null) {
          await prefs.setString('profileImage', jsonResponse['image_url']);
          setState(() {
            profileImageUrl = jsonResponse['image_url'];
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update profile image: ${jsonResponse['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullProfileImageUrl =
        profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? baseurl.replaceAll('/api', '') + profileImageUrl!
            : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : fullProfileImageUrl.isNotEmpty
                                        ? NetworkImage(fullProfileImageUrl)
                                        : AssetImage(
                                                "assets/images/broken-image.png")
                                            as ImageProvider,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userDetails?['username'] ?? "User",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        userDetails?['role'] ?? "Role",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Rest of your UI components remain the same...
                buildSectionTitle(
                  "Personal Information",
                  isEditable: true,
                  onEditPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPersonalInfoScreen(),
                      ),
                    );
                  },
                ),
                buildInfoTile(Icons.calendar_today, "Date of Birth",
                    personalDetails?['date_of_birth'] ?? "N/A"),
                buildInfoTile(Icons.person, "Gender",
                    personalDetails?['gender'] ?? "N/A"),
                buildInfoTile(Icons.bloodtype, "Blood Group",
                    personalDetails?['blood_group'] ?? "N/A"),
                buildInfoTile(Icons.public, "Nationality",
                    personalDetails?['nationality'] ?? "N/A"),
                SizedBox(height: 10),
                buildSectionTitle(
                  "Additional Information",
                  isEditable: true,
                  onEditPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdditionalDetailsScreen(),
                      ),
                    );
                  },
                ),
                buildInfoTile(
                    Icons.map, "State", additionalDetails?['state'] ?? "N/A"),
                buildInfoTile(Icons.location_city, "District",
                    additionalDetails?['district'] ?? "N/A"),
                buildInfoTile(Icons.pin, "Pincode",
                    additionalDetails?['pincode'] ?? "N/A"),
                buildInfoTile(
                    Icons.phone, "Phone", additionalDetails?['phone'] ?? "N/A"),
                buildInfoTile(Icons.description, "Bio",
                    additionalDetails?['bio'] ?? "N/A"),
                SizedBox(height: 10),
                buildSectionTitle(
                  "Account Information",
                  isEditable: true,
                  onEditPressed: () async {
                    final updatedUserDetails = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAccountInformationScreen(
                          userDetails: userDetails,
                        ),
                      ),
                    );
                    if (updatedUserDetails != null) {
                      setState(() {
                        userDetails = updatedUserDetails;
                      });
                    }
                  },
                ),
                buildInfoTile(Icons.person, "Username",
                    userDetails?['username'] ?? "N/A"),
                buildInfoTile(
                    Icons.email, "Email", userDetails?['email'] ?? "N/A"),
                buildInfoTile(Icons.assignment_ind, "Role",
                    userDetails?['role'] ?? "N/A"),
              ],
            ),
          ),
          if (_isUploading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(
    String title, {
    bool isEditable = true,
    VoidCallback? onEditPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (isEditable)
            ElevatedButton.icon(
              onPressed: onEditPressed,
              icon: Icon(Icons.edit, size: 18),
              label: Text("Edit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.1),
                foregroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildInfoTile(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Divider(color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
