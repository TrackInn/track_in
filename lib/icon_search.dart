import 'package:flutter/material.dart';
import 'package:track_in/feedback_form.dart';
import 'package:track_in/profile.dart';
import 'package:track_in/send_notificatioin.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Map<String, dynamic>> items = [
    {
      'icon': Icons.send,
      'label': 'Send Notification',
      'route': SendNotificationScreen()
    },
    {'icon': Icons.feedback, 'label': 'Feedback', 'route': FeedbackForm()},
    {'icon': Icons.person, 'label': 'Profile', 'route': ProfileScreen()},
    {'icon': Icons.settings, 'label': 'Settings', 'route': SettingsScreen()},
    {'icon': Icons.lock, 'label': 'Security', 'route': SecurityScreen()},
    {'icon': Icons.help, 'label': 'Help', 'route': HelpScreen()},
  ];

  List<Map<String, dynamic>> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = []; // List to store search history

  @override
  void initState() {
    super.initState();
    filteredItems = items;
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = items
          .where((item) =>
              item['label'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addToSearchHistory(String query) {
    if (query.isNotEmpty && !searchHistory.contains(query)) {
      setState(() {
        searchHistory.insert(0, query); // Add new query to the top of the list
        if (searchHistory.length > 5) {
          searchHistory.removeLast(); // Keep only the last 5 searches
        }
      });
    }
  }

  void clearSearchHistory() {
    setState(() {
      searchHistory.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: "Search here...",
                          border: InputBorder.none,
                        ),
                        onChanged: (query) {
                          filterItems(query);
                          if (query.isEmpty) {
                            setState(() {
                              filteredItems = items; // Reset to show all items
                            });
                          }
                        },
                        onSubmitted: (query) {
                          addToSearchHistory(query); // Add query to history
                        },
                      ),
                    ),
                  ),
                  // Search Icon
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search History
          if (searchHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        onPressed: clearSearchHistory,
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: searchHistory.map((query) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = query;
                          filterItems(query);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            query,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          // Grid View for Icons
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1, // Square items
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => filteredItems[index]['route']),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with Circular Background
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.1),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            )
                          ],
                        ),
                        child: Icon(filteredItems[index]['icon'],
                            size: 26, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        filteredItems[index]['label'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, height: 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text('Settings Screen')),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security')),
      body: Center(child: Text('Security Screen')),
    );
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: Center(child: Text('Help Screen')),
    );
  }
}
