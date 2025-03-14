import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _privacyEnabled = false;

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
                // Show basic app version details in a dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('About the App'),
                      content:
                          Text('App Version: 1.0.0\nDeveloped by TrackIn Team'),
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
