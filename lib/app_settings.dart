import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _privacyEnabled = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode Setting
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.brightness_6, color: Colors.blue),
              title: Text('Theme Mode'),
              subtitle: Text(_isDarkMode ? 'Dark Mode' : 'Light Mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // Add logic to change app theme
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Setting
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text('Notifications'),
              subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // Add logic to enable/disable notifications
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Setting
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.language, color: Colors.blue),
              title: Text('Language'),
              subtitle: Text(_selectedLanguage),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                  // Add logic to change app language
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Privacy Setting
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.blue),
              title: Text('Privacy'),
              subtitle: Text(_privacyEnabled ? 'Enabled' : 'Disabled'),
              trailing: Switch(
                value: _privacyEnabled,
                onChanged: (value) {
                  setState(() {
                    _privacyEnabled = value;
                  });
                  // Add logic to enable/disable privacy settings
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About the App
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('About the App'),
              subtitle: Text('Version 1.0.0'),
              onTap: () {
                // Navigate to About Screen or show a dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('About the App'),
                      content: Text(
                          'This is a sample app demonstrating basic settings.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
