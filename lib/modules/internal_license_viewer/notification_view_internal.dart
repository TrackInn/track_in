import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:track_in/baseurl.dart'; // Ensure this import points to your base URL file

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [];
  bool isMultiSelectMode = false;
  Set<String> selectedNotifications = {};
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // Fetch notifications from the API
  void _fetchNotifications() async {
    try {
      String userRole = "internal_license_viewer"; // Replace with actual role
      List<NotificationItem> fetchedNotifications =
          await _notificationService.fetchNotifications(userRole);
      setState(() {
        notifications = fetchedNotifications;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
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
  void deleteSelectedNotifications() {
    setState(() {
      notifications.removeWhere(
          (notification) => selectedNotifications.contains(notification.id));
      selectedNotifications.clear();
      isMultiSelectMode = false;
    });
  }

  // Add selected notifications to favorites
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('All'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Favourite'),
              ),
              TextButton(
                onPressed: markAllAsRead,
                child: Text('Mark All Read'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      notifications.removeAt(index);
                    });
                  },
                  child: ListTile(
                    leading: isMultiSelectMode
                        ? Checkbox(
                            value:
                                selectedNotifications.contains(notification.id),
                            onChanged: (value) =>
                                toggleSelection(notification.id),
                          )
                        : null,
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
  final String apiUrl = "$baseurl/licensenotifications/";

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
}
