import 'package:flutter/material.dart';
import 'package:track_in/modules/internal_license_viewer/internal_viewer_license_list.dart';
import 'package:track_in/modules/internal_license_viewer/internal_viewer_dashboard.dart';
import 'package:track_in/profile.dart';
import 'package:flutter/services.dart';

class RootScreenLicenseInternalViewer extends StatefulWidget {
  @override
  _RootScreenLicenseInternalViewer createState() =>
      _RootScreenLicenseInternalViewer();
}

class _RootScreenLicenseInternalViewer
    extends State<RootScreenLicenseInternalViewer> {
  int _selectedIndex = 0; // Track the selected index

  // List of screens to display for each tab
  final List<Widget> _screens = [
    InternalViewerDashboard(),
    Scaffold(), // Placeholder for Calendar screen
    InternalViewerLicenseList(),
    ProfileScreen(),
  ];

  // Handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog when the back button is pressed
        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // Close the dialog
                  SystemNavigator.pop(); // Exit the app
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );

        // Return false to prevent default back button behavior
        return false;
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomBarHeight = screenHeight * 0.07; // 7% of screen height

    return BottomAppBar(
      color: Colors.white,
      child: Container(
        height: bottomBarHeight, // Responsive height
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home, "Home", 0),
            _buildNavBarItem(Icons.calendar_month, "Calendar", 1),
            _buildNavBarItem(Icons.description, "License", 2),
            _buildNavBarItem(Icons.account_circle, "Account", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Icon(
            icon,
            size: 29,
            color:
                _selectedIndex == index ? Colors.blue : const Color(0xFFB0B9E0),
          ),
          onTap: () {
            _onItemTapped(index);
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                _selectedIndex == index ? Colors.blue : const Color(0xFFB0B9E0),
          ),
        ),
      ],
    );
  }
}
