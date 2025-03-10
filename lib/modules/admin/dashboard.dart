import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0; // Track the active sidebar item

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Navigation Bar (starts from the leftmost end)
          TopNavigationBar(),

          // Main Content Area (sidebar and main content)
          Expanded(
            child: Row(
              children: [
                // Left Sidebar (Visible on larger screens)
                if (MediaQuery.of(context).size.width > 600)
                  Sidebar(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),

                // Main Content and Right Sidebar
                Expanded(
                  child: Column(
                    children: [
                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WelcomeSection(),
                              StatisticsSection(),
                              PieChartsAndCalendarSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Sidebar
                RightSidebar(),
              ],
            ),
          ),
        ],
      ),

      // Drawer for smaller screens
      drawer: MediaQuery.of(context).size.width <= 600
          ? Drawer(
              child: Sidebar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            )
          : null,
    );
  }
}

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Sidebar({required this.selectedIndex, required this.onItemTapped});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isAddOptionsExpanded = false; // Track if "Add" dropdown is expanded
  bool _isManageOptionsExpanded =
      false; // Track if "Manage" dropdown is expanded

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 275,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.black12, // Stroke color
            width: 1, // Stroke width
          ),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and
          SizedBox(height: 16), // Reduced gap

          // Navigation Items
          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
          _buildNavItem(Icons.person, 'Account', 1),
          _buildNavItem(Icons.inbox, 'Inbox', 2),
          _buildNavItem(Icons.people, 'Users', 3),
          // Add Options Dropdown
          _buildDropdown(
            isExpanded: _isAddOptionsExpanded,
            title: 'Add',
            icon: Icons.add,
            children: [
              _buildDropdownItem('Add License', 6),
              _buildDropdownItem('Add Tender', 7),
              _buildDropdownItem('Add PNDT', 8),
            ],
            onTap: () {
              setState(() {
                _isAddOptionsExpanded = !_isAddOptionsExpanded;
              });
            },
          ),

          // Manage Options Dropdown
          _buildDropdown(
            isExpanded: _isManageOptionsExpanded,
            title: 'Manage',
            icon: Icons.manage_accounts,
            children: [
              _buildDropdownItem('Manage License', 9),
              _buildDropdownItem('Manage Tender', 10),
              _buildDropdownItem('Manage PNDT', 11),
            ],
            onTap: () {
              setState(() {
                _isManageOptionsExpanded = !_isManageOptionsExpanded;
              });
            },
          ),

          Spacer(),
          _buildNavItem(Icons.settings, 'Settings', 5),
          _buildNavItem(Icons.logout, 'Logout', 12),
        ],
      ),
    );
  }

  // Helper method to build a navigation item
  Widget _buildNavItem(IconData icon, String label, int index) {
    return Container(
      decoration: BoxDecoration(
        color: widget.selectedIndex == index ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: widget.selectedIndex == index ? Colors.white : Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            color: widget.selectedIndex == index ? Colors.white : Colors.grey,
            fontSize: 14,
          ),
        ),
        onTap: () => widget.onItemTapped(index),
      ),
    );
  }

  // Helper method to build a dropdown list
  Widget _buildDropdown({
    required bool isExpanded,
    required String title,
    required IconData icon,
    required List<Widget> children,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        if (isExpanded) ...children, // Show children if expanded
      ],
    );
  }

  // Helper method to build a dropdown item
  Widget _buildDropdownItem(String label, int index) {
    return Padding(
      padding: EdgeInsets.only(left: 32), // Indent dropdown items
      child: _buildNavItem(Icons.arrow_right, label, index),
    );
  }
}

class TopNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width, // Span the entire width
      child: Row(
        children: [
          // Hamburger Menu and TRACKIN Logo
          Icon(Icons.menu, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'TRACKIN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 16), // Add some spacing

          // Search Bar
          Container(
            width: 400, // Fixed width for the search bar
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20), // Curved edges
            ),
            child: TextField(
              textAlignVertical:
                  TextAlignVertical.center, // Aligns text vertically center
              textAlign: TextAlign.left, // Aligns text to the left
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
            ),
          ),

          Spacer(), // Pushes the profile section to the right
          // Profile Section
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    AssetImage('assets/profile.jpg'), // Add a profile image
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Franklin Jr.',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Super Admin',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome To Your Document Management Area',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Organize, store, and access documents easily with our secure management system.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Image.asset('assets/welcome_illustration.png',
              height: 120), // Add an illustration
        ],
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate the width of each card based on the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 4; // 48 = padding (16 * 3 gaps)
    final cardHeight = 155.0; // Fixed height for all cards

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true, // Ensure the grid doesn't overflow
        physics: NeverScrollableScrollPhysics(), // Disable scrolling
        crossAxisCount: screenWidth > 600
            ? 4
            : 2, // 4 cards in a row for larger screens, 2 for smaller
        childAspectRatio:
            cardWidth / cardHeight, // Adjust aspect ratio dynamically
        crossAxisSpacing: 16, // Horizontal spacing between cards
        mainAxisSpacing: 16, // Vertical spacing between cards
        children: [
          _buildStatCard(
              'Total Users', '2,318', Colors.blueAccent, cardWidth, cardHeight),
          _buildStatCard('Total CDSCO Licenses', '7,265', Colors.greenAccent,
              cardWidth, cardHeight),
          _buildStatCard('Total Tenders', '156', Colors.orangeAccent, cardWidth,
              cardHeight),
          _buildStatCard('Total PC & PNDT Licenses', '3,671',
              Colors.purpleAccent, cardWidth, cardHeight),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color,
      double cardWidth, double cardHeight) {
    return Container(
      width: cardWidth, // Set the width dynamically
      height: cardHeight, // Set the fixed height
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class PieChartsAndCalendarSection extends StatefulWidget {
  @override
  _PieChartsAndCalendarSectionState createState() =>
      _PieChartsAndCalendarSectionState();
}

class _PieChartsAndCalendarSectionState
    extends State<PieChartsAndCalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showPercentage = true; // Toggle between percentage and count

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        children: [
          // Pie Charts Section
          Expanded(
            flex: 4, // Adjusted flex to accommodate the reduced calendar width
            child: Container(
              height: 325, // Match the height of the calendar
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black12, // Stroke color
                  width: 1, // Stroke width
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the content vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Text and Radio Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        Row(
                          children: [
                            Text("Count",
                                style: TextStyle(color: Colors.blueGrey[600])),
                            Radio(
                              value: false,
                              groupValue: _showPercentage,
                              onChanged: (value) {
                                setState(() {
                                  _showPercentage = value as bool;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                            Text("Percentage",
                                style: TextStyle(color: Colors.blueGrey[600])),
                            Radio(
                              value: true,
                              groupValue: _showPercentage,
                              onChanged: (value) {
                                setState(() {
                                  _showPercentage = value as bool;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Pie Charts
                    Expanded(
                      child: Center(
                        // Center the pie charts vertically
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPieChart(
                              "Active CDSCO License",
                              81,
                              Colors.red,
                              _showPercentage ? "81%" : "7,265",
                            ),
                            _buildPieChart(
                              "Pending EMD",
                              22,
                              Colors.green,
                              _showPercentage ? "22%" : "156",
                            ),
                            _buildPieChart(
                              "Active PC & PNDT Licenses",
                              62,
                              Colors.blue,
                              _showPercentage ? "62%" : "3,671",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16), // Add spacing between pie charts and calendar
          // Calendar
          Container(
            width: 280, // Fixed width for the calendar
            height: 325, // Set height to 325
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black12, // Stroke color
                width: 1, // Stroke width
              ),
              color: Colors.white, // Background color of the container
            ),
            child: Card(
              color: Colors.white,
              elevation: 0, // Set elevation to 0 to remove shadow from the Card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(8), // Reduced padding to fit content
                child: Column(
                  children: [
                    Container(
                      height: 260, // Constrain the height of the calendar
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false, // Hide the format button
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 14, // Reduced font size for the header
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            size: 20, // Reduced size of the previous button
                            color: Colors.blueGrey[800],
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            size: 20, // Reduced size of the next button
                            color: Colors.blueGrey[800],
                          ),
                          headerMargin:
                              EdgeInsets.only(bottom: 8), // Reduced margin
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle:
                              TextStyle(color: Colors.white, fontSize: 12),
                          // Style for default text
                          defaultTextStyle: TextStyle(
                              fontSize: 12, color: Colors.blueGrey[800]),
                          // Style for weekend text
                          weekendTextStyle: TextStyle(
                              fontSize: 12, color: Colors.blueGrey[800]),
                          // Style for days outside the current month
                          outsideTextStyle: TextStyle(
                              fontSize: 12, color: Colors.blueGrey[400]),
                        ),
                        daysOfWeekHeight:
                            32, // Reduced height of days of the week
                        rowHeight: 32, // Reduced row height
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
      String title, double percentage, Color color, String value) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the pie chart and text
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: percentage,
                      color: color,
                      radius: 25,
                      title: "",
                    ),
                    PieChartSectionData(
                      value: 100 - percentage,
                      color: color.withOpacity(0.2),
                      radius: 25,
                      title: "",
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[800]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class RightSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Colors.black12, // Border color
            width: 1, // Border width
          ),
        ),
      ),
      width: 275,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            _buildNotification('You fixed a bug.', 'Just now'),
            _buildNotification('New user registered.', '59 minutes ago'),
            _buildNotification(
                'Andi Lane subscribed to you.', 'Today, 11:59 AM'),
            SizedBox(height: 16),

            // Activities Section
            Text(
              'Activities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            _buildActivity('Changed the style.'),
            _buildActivity('Released a new version.', '59 minutes ago'),
            _buildActivity('Submitted a bug.', '12 hours ago'),
            SizedBox(height: 16),

            // Contacts Section
            Text(
              'Contacts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            _buildContact('Natali Craig'),
            _buildContact('Drew Cano'),
            _buildContact('Andi Lane'),
          ],
        ),
      ),
    );
  }

  // Helper method to build a notification item
  Widget _buildNotification(String text, String time) {
    return ListTile(
      leading: Icon(Icons.notifications, color: Colors.grey),
      title: Text(text),
      subtitle: Text(
        time,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // Helper method to build an activity item
  Widget _buildActivity(String text, [String? time]) {
    return ListTile(
      leading: Icon(Icons.history, color: Colors.grey),
      title: Text(text),
      subtitle: time != null
          ? Text(
              time,
              style: TextStyle(color: Colors.grey),
            )
          : null,
    );
  }

  // Helper method to build a contact item
  Widget _buildContact(String name) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/$name.jpg'), // Add contact images
      ),
      title: Text(name),
    );
  }
}
