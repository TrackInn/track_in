import 'package:flutter/material.dart';

class AdminAddUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New User'),
      ),
      body: Center(
        child: Text('Add New User Screen'),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UsersPage(),
      routes: {
        '/addUser': (context) => AdminAddUserScreen(),
        '/editUser': (context) => EditUserScreen(),
      },
    );
  }
}

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String? selectedRole; // Track the selected role for filtering
  String? isApprovedFilter; // Track the "Is Approved" filter
  String searchQuery = ''; // Track the search query

  // List of roles for filtering
  final List<String> roles = [
    'All',
    'License Manager',
    'Internal License Viewer',
    'External License Viewer',
    'Tender Manager',
    'Tender Viewer',
    'PNDT Manager',
    'PNDT Viewer',
  ];

  // List of "Is Approved" filter options
  final List<String> isApprovedOptions = ['All', 'Yes', 'No'];

  // List of all users
  final List<Map<String, dynamic>> users = [
    {
      'name': 'John Doe',
      'role': 'License Manager',
      'phone': '+12 345 6789 0',
      'email': 'john.doe@mail.com',
      'isApproved': true
    },
    {
      'name': 'Jane Smith',
      'role': 'Internal License Viewer',
      'phone': '+12 345 6789 1',
      'email': 'jane.smith@mail.com',
      'isApproved': false
    },
    {
      'name': 'Alice Johnson',
      'role': 'External License Viewer',
      'phone': '+12 345 6789 2',
      'email': 'alice.johnson@mail.com',
      'isApproved': true
    },
    {
      'name': 'Bob Brown',
      'role': 'Tender Manager',
      'phone': '+12 345 6789 3',
      'email': 'bob.brown@mail.com',
      'isApproved': false
    },
    {
      'name': 'Charlie Davis',
      'role': 'Tender Viewer',
      'phone': '+12 345 6789 4',
      'email': 'charlie.davis@mail.com',
      'isApproved': true
    },
    {
      'name': 'Eva Wilson',
      'role': 'PNDT Manager',
      'phone': '+12 345 6789 5',
      'email': 'eva.wilson@mail.com',
      'isApproved': false
    },
    {
      'name': 'Frank White',
      'role': 'PNDT Viewer',
      'phone': '+12 345 6789 6',
      'email': 'frank.white@mail.com',
      'isApproved': true
    },
    {
      'name': 'Grace Lee',
      'role': 'License Manager',
      'phone': '+12 345 6789 7',
      'email': 'grace.lee@mail.com',
      'isApproved': false
    },
    {
      'name': 'Henry Clark',
      'role': 'Internal License Viewer',
      'phone': '+12 345 6789 8',
      'email': 'henry.clark@mail.com',
      'isApproved': true
    },
    {
      'name': 'Ivy Walker',
      'role': 'External License Viewer',
      'phone': '+12 345 6789 9',
      'email': 'ivy.walker@mail.com',
      'isApproved': false
    },
  ];

  // Get filtered users based on the selected role, "Is Approved" filter, and search query
  List<Map<String, dynamic>> get filteredUsers {
    List<Map<String, dynamic>> filtered = users;

    // Apply role filter
    if (selectedRole != null && selectedRole != 'All') {
      filtered =
          filtered.where((user) => user['role'] == selectedRole).toList();
    }

    // Apply "Is Approved" filter
    if (isApprovedFilter != null && isApprovedFilter != 'All') {
      final isApproved = isApprovedFilter == 'Yes';
      filtered =
          filtered.where((user) => user['isApproved'] == isApproved).toList();
    }

    // Apply search query filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = user['name']!.toLowerCase();
        final role = user['role']!.toLowerCase();
        final email = user['email']!.toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) ||
            role.contains(query) ||
            email.contains(query);
      }).toList();
    }

    return filtered;
  }

  // Clear all filters
  void clearFilters() {
    setState(() {
      selectedRole = null;
      isApprovedFilter = null;
    });
  }

  // Navigate to Add User Screen
  void navigateToAddUser() {
    Navigator.pushNamed(context, '/addUser');
  }

  // Navigate to Edit User Screen
  void navigateToEditUser(Map<String, dynamic> user) {
    Navigator.pushNamed(context, '/editUser', arguments: user);
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to remove $userName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle delete logic here
                setState(() {
                  users.removeWhere((user) => user['name'] == userName);
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://placehold.co/40x40',
                          height: 40,
                          width: 40,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Kleon',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Main Menu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.dashboard, color: Colors.grey),
                        title: Text('Dashboard'),
                        onTap: () {
                          // Navigate to Dashboard
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.grey),
                        title: Text('Account'),
                        onTap: () {
                          // Navigate to Account
                        },
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.email, color: Colors.grey),
                        title: Text('Inbox'),
                        trailing: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            '17',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        children: [
                          ListTile(
                            title: Text('Feedback'),
                            onTap: () {
                              // Navigate to Feedback
                            },
                          ),
                          ListTile(
                            title: Text('Notifications'),
                            onTap: () {
                              // Navigate to Notifications
                            },
                          ),
                        ],
                      ),
                      ListTile(
                        leading: Icon(Icons.group, color: Colors.grey),
                        title: Text('Users'),
                        tileColor: Colors.grey.shade200,
                        onTap: () {
                          // Navigate to Users
                        },
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.file_copy, color: Colors.grey),
                        title: Text('Documents'),
                        children: [
                          ListTile(
                            title: Text('Cdsco Licences'),
                            onTap: () {
                              // Navigate to Cdsco Licences
                            },
                          ),
                          ListTile(
                            title: Text('Tenders'),
                            onTap: () {
                              // Navigate to Tenders
                            },
                          ),
                          ListTile(
                            title: Text('Pndt Licences'),
                            onTap: () {
                              // Navigate to Pndt Licences
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey),
                  title: Text('Settings'),
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.grey),
                  title: Text('Logout'),
                  onTap: () {
                    // Handle Logout
                  },
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar (End-to-End)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search Bar
                      Container(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search here',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(24.0), // Capsule shape
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                      // Icons and Profile
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.grey),
                          SizedBox(width: 16),
                          Icon(Icons.notifications, color: Colors.grey),
                          SizedBox(width: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage('https://placehold.co/30x30'),
                                radius: 15,
                              ),
                              SizedBox(width: 8),
                              Text('ENGLISH'),
                            ],
                          ),
                          SizedBox(width: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage('https://placehold.co/30x30'),
                                radius: 20,
                              ),
                              SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Franklin Jr.'),
                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Users Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Users Heading and Search Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Users',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                // Capsule-shaped Search Bar
                                Container(
                                  width: 200,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search here',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            24.0), // Capsule shape
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0,
                                      ),
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Filter Button with Role-Based Options
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    setState(() {
                                      if (value.startsWith('role:')) {
                                        selectedRole =
                                            value.replaceFirst('role:', '');
                                      } else if (value
                                          .startsWith('approved:')) {
                                        isApprovedFilter =
                                            value.replaceFirst('approved:', '');
                                      }
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      // Role Filter Options
                                      PopupMenuItem(
                                        value: 'role:All',
                                        child: Text('All Roles'),
                                      ),
                                      ...roles.map((role) {
                                        return PopupMenuItem(
                                          value: 'role:$role',
                                          child: Text(role),
                                        );
                                      }).toList(),
                                      // Divider
                                      PopupMenuDivider(),
                                      // "Is Approved" Filter Options
                                      PopupMenuItem(
                                        value: 'approved:All',
                                        child: Text('All Approval Statuses'),
                                      ),
                                      ...isApprovedOptions.map((option) {
                                        return PopupMenuItem(
                                          value: 'approved:$option',
                                          child: Text(option),
                                        );
                                      }).toList(),
                                    ];
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.filter_list,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Filter',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Clear Filter Button
                                if (selectedRole != null ||
                                    isApprovedFilter != null)
                                  ElevatedButton(
                                    onPressed: clearFilters,
                                    child: Text(
                                      'Clear Filter',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                        vertical: 16.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            24.0), // Rounded shape
                                      ),
                                      elevation: 4, // Add shadow
                                    ),
                                  ),
                                SizedBox(width: 16),
                                // Attractive Add New User Button
                                ElevatedButton(
                                  onPressed: navigateToAddUser,
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_add,
                                          color: Colors.white), // Add icon
                                      SizedBox(width: 8),
                                      Text(
                                        'Add New User',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                      vertical: 16.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          24.0), // Rounded shape
                                    ),
                                    elevation: 4, // Add shadow
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // User Cards Grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.of(context).size.width > 600
                                      ? 5
                                      : 3, // 5 cards per row
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio:
                                  0.9, // Adjusted for better content fit
                            ),
                            itemCount:
                                filteredUsers.length, // Number of user cards
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return UserCard(
                                name: user['name']!,
                                role: user['role']!,
                                phone: user['phone']!,
                                email: user['email']!,
                                isApproved: user['isApproved'],
                                imageUrl:
                                    'https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250',
                                onEdit: () => navigateToEditUser(user),
                                onDelete: () => showDeleteConfirmation(
                                    context, user['name']!),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final String email;
  final bool isApproved;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.isApproved,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0), // Adjusted padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Three-dot menu in the top-right corner
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey, size: 20),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(); // Handle Edit
                } else if (value == 'delete') {
                  onDelete(); // Handle Delete
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image (Square with rounded edges)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  height: 60, // Adjusted image size
                  width: 60, // Adjusted image size
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 12), // Adjusted spacing
              // User Name
              Text(
                name,
                style: TextStyle(
                  fontSize: 16, // Adjusted font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6), // Adjusted spacing
              // Role
              Text(
                role,
                style: TextStyle(
                  fontSize: 14, // Adjusted font size
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 6), // Adjusted spacing
              // Approval Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isApproved ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isApproved ? 'Approved' : 'Not Approved',
                  style: TextStyle(
                    fontSize: 12,
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12), // Adjusted spacing
              // Phone with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Icon(Icons.phone,
                        color: Colors.blue, size: 16), // Adjusted icon size
                  ),
                  SizedBox(width: 4),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 14, // Adjusted font size
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8), // Adjusted spacing
              // Email with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Icon(Icons.email,
                        color: Colors.blue, size: 16), // Adjusted icon size
                  ),
                  SizedBox(width: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14, // Adjusted font size
                      color: Colors.grey,
                    ),
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

// Placeholder screens for Add User and Edit User
class AddUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New User'),
      ),
      body: Center(
        child: Text('Add New User Screen'),
      ),
    );
  }
}

class EditUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Center(
        child: Text('Editing ${user['name']}'),
      ),
    );
  }
}
