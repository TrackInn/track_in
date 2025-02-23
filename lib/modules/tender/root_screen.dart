import 'package:flutter/material.dart';
import 'package:track_in/modules/tender/tender_manager.dart';
import 'package:track_in/modules/tender/tender_add.dart';
import 'package:track_in/modules/tender/tenderlist.dart';
import 'package:track_in/profile.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // Track the selected index

  // List of screens to display for each tab
  final List<Widget> _screens = [
    TenderManager(),
    Scaffold(),
    Tenderlist(),
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
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 0), // Increased padding to the FAB
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TenderForm(),
                ));
          },
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomBarHeight = screenHeight * 0.07; // 7% of screen height

    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0, // Reduced notch margin
      child: Container(
        height: bottomBarHeight, // Responsive height
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home, "Home", 0),
            _buildNavBarItem(Icons.calendar_month, "Calendar", 1),
            const SizedBox(width: 40), // Space for the floating action button
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
