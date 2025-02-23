import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      heading: 'New Message',
      description: 'You have a new message from John Doe.',
      time: '10:00 AM',
      isRead: false,
      isFavourite: false,
    ),
    NotificationItem(
      id: '2',
      heading: 'Reminder',
      description: 'Don’t forget to complete your task by today.',
      time: '11:30 AM',
      isRead: false,
      isFavourite: false,
    ),
    NotificationItem(
      id: '3',
      heading: 'Promotion',
      description: 'Get 50% off on your next purchase.',
      time: '12:45 PM',
      isRead: true,
      isFavourite: true,
    ),
  ];

  bool isMultiSelectMode = false;
  Set<String> selectedNotifications = {};

  void toggleMultiSelectMode() {
    setState(() {
      isMultiSelectMode = !isMultiSelectMode;
      if (!isMultiSelectMode) {
        selectedNotifications.clear();
      }
    });
  }

  void toggleSelection(String id) {
    setState(() {
      if (selectedNotifications.contains(id)) {
        selectedNotifications.remove(id);
      } else {
        selectedNotifications.add(id);
      }
    });
  }

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void deleteSelectedNotifications() {
    setState(() {
      notifications.removeWhere(
          (notification) => selectedNotifications.contains(notification.id));
      selectedNotifications.clear();
      isMultiSelectMode = false;
    });
  }

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
                      notification.heading,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.description),
                        SizedBox(height: 4),
                        Text(
                          notification.time,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () => showNotificationDetails(
                          context, notification.description),
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

class NotificationItem {
  String id;
  String heading;
  String description;
  String time;
  bool isRead;
  bool isFavourite;

  NotificationItem({
    required this.id,
    required this.heading,
    required this.description,
    required this.time,
    required this.isRead,
    required this.isFavourite,
  });
}
