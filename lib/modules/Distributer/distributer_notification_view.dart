import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart'; // Ensure this import points to your base URL file

class DistributerNotification extends StatefulWidget {
  @override
  _DistributerNotificationState createState() =>
      _DistributerNotificationState();
}

class _DistributerNotificationState extends State<DistributerNotification> {
  List<NotificationItem> notifications = [];
  bool isMultiSelectMode = false;
  Set<String> selectedNotifications = {};
  final NotificationService _notificationService = NotificationService();

  // Track the selected option
  String _selectedOption = 'All';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // Fetch notifications from the API
  void _fetchNotifications([String? filter]) async {
    try {
      String userRole = "external_license_viewer"; // Use the correct role
      List<NotificationItem> fetchedNotifications =
          await _notificationService.fetchNotifications(userRole);

      // Apply filter based on the selected option
      if (filter == 'Favourites') {
        fetchedNotifications =
            fetchedNotifications.where((n) => n.isFavourite).toList();
      }

      setState(() {
        notifications = fetchedNotifications;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch notifications: $e")),
      );
    }
  }

  // Toggle multi-select mode
  void toggleMultiSelectMode() {
    setState(() {
      isMultiSelectMode = !isMultiSelectMode;
      if (!isMultiSelectMode) {
        selectedNotifications.clear();
      }
    });
  }

  // Toggle selection of a notification
  void toggleSelection(String id) {
    setState(() {
      if (selectedNotifications.contains(id)) {
        selectedNotifications.remove(id);
      } else {
        selectedNotifications.add(id);
      }
    });
  }

  // Mark all notifications as read
  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  // Delete selected notifications
  void deleteSelectedNotifications() async {
    if (selectedNotifications.isEmpty) return;

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content:
            Text('Are you sure you want to delete the selected notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // Call the delete API for each selected notification
      for (var id in selectedNotifications) {
        await _notificationService.deleteNotification(id);
      }

      // Remove the notifications from the list
      setState(() {
        notifications.removeWhere(
            (notification) => selectedNotifications.contains(notification.id));
        selectedNotifications.clear();
        isMultiSelectMode = false;
      });

      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected notifications deleted'),
        ),
      );
    }
  }

  // Add selected notifications to favourites
  void addSelectedToFavourites() {
    setState(() {
      for (var notification in notifications) {
        if (selectedNotifications.contains(notification.id)) {
          notification.isFavourite = true;
        }
      }
      selectedNotifications.clear();
      isMultiSelectMode = false;
    });

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected notifications added to favourites'),
      ),
    );
  }

  // Show notification details in a bottom sheet
  void showNotificationDetails(BuildContext context, String description) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(description),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle option selection
  void _onOptionSelected(String option) {
    setState(() {
      _selectedOption = option;
    });

    // Fetch notifications based on the selected option
    if (option == 'All') {
      _fetchNotifications();
    } else if (option == 'Favourites') {
      _fetchNotifications('Favourites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white), // AppBar heading color white
        ),
        backgroundColor: Colors.blue, // AppBar color blue
        iconTheme:
            IconThemeData(color: Colors.white), // AppBar icons color white
        actions: [
          if (isMultiSelectMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: deleteSelectedNotifications,
            ),
          if (isMultiSelectMode)
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: addSelectedToFavourites,
            ),
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: toggleMultiSelectMode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dividing line
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[300],
          ),
          // Options Row
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left-aligned options (All, Favourites)
                Row(
                  children: [
                    _buildOptionButton('All'),
                    SizedBox(width: 16),
                    _buildOptionButton('Favourites'),
                  ],
                ),
              ],
            ),
          ),
          // Dividing line
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[300],
          ),
          // Notifications List
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Delete', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 10),
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Edit action
                      // Navigate to edit screen if needed
                      return false; // Do not dismiss the item
                    } else {
                      // Show confirmation dialog for delete action
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete this notification?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmDelete == true) {
                        // Call the delete API
                        await _notificationService
                            .deleteNotification(notification.id);
                        setState(() {
                          notifications.removeAt(index);
                        });

                        // Show SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Notification deleted'),
                          ),
                        );

                        return true; // Dismiss the item
                      } else {
                        return false; // Do not dismiss the item
                      }
                    }
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                    title: Text(
                      notification.heading ?? 'No Title',
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.description ?? 'No Description'),
                        SizedBox(height: 4),
                        Text(
                          notification.time ?? 'No Time',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () => showNotificationDetails(
                          context, notification.description ?? 'No Details'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build an option button with animated underline
  Widget _buildOptionButton(String option) {
    return GestureDetector(
      onTap: () => _onOptionSelected(option),
      child: Column(
        children: [
          Text(
            option,
            style: TextStyle(
              color: _selectedOption == option ? Colors.blue : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 2,
            width: _selectedOption == option ? 40 : 0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

// Notification Item Model
class NotificationItem {
  String id;
  String? heading;
  String? description;
  String? time;
  bool isRead;
  bool isFavourite;

  NotificationItem({
    required this.id,
    this.heading,
    this.description,
    this.time,
    this.isRead = false,
    this.isFavourite = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '0', // Default ID if null
      heading: json['title']?.toString(), // Nullable field
      description: json['content']?.toString(), // Nullable field
      time: json['time']?.toString(), // Nullable field
      isRead: json['isRead'] ?? false, // Default to false if null
      isFavourite: json['isFavourite'] ?? false, // Default to false if null
    );
  }
}

// Notification Service to fetch data from the API
class NotificationService {
  final String apiUrl = "$baseurl/externalviewernotification/";

  Future<List<NotificationItem>> fetchNotifications(String role) async {
    final response = await http.get(Uri.parse("$apiUrl?role=$role"));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<NotificationItem> notifications = body
          .map(
            (dynamic item) => NotificationItem.fromJson(item),
          )
          .toList();
      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Delete notification API call
  Future<void> deleteNotification(String id) async {
    final String deleteUrl = "$baseurl/updatenotification/";
    final response = await http.delete(
      Uri.parse(deleteUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      print("Notification deleted successfully");
    } else {
      throw Exception('Failed to delete notification');
    }
  }
}
