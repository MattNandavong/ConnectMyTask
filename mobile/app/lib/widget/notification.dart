import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadNotifications(); // Refresh notifications on resume
    }
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('notifications') ?? [];
    final now = DateTime.now();

    final validNotifications =
        stored
            .map((jsonStr) {
              try {
                final n = jsonDecode(jsonStr) as Map<String, dynamic>;
                final ts = DateTime.tryParse(n['timestamp'] ?? '');
                if (ts == null || now.difference(ts).inDays >= 7) return null;
                return n;
              } catch (_) {
                return null;
              }
            })
            .where((n) => n != null)
            .cast<Map<String, dynamic>>()
            .toList();

    notifications = validNotifications.reversed.toList(); // Newest first
    await _saveNotifications(); // Save cleaned
    setState(() {});
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = notifications.reversed.map((n) => jsonEncode(n)).toList();
    await prefs.setStringList('notifications', data);
  }

  void markAsRead(int index) async {
    setState(() {
      notifications[index]['read'] = true;
    });
    await _saveNotifications();
  }

  void deleteNotification(int index) async {
    setState(() {
      notifications.removeAt(index);
    });
    await _saveNotifications();
  }

  void clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    setState(() => notifications.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: notifications.isEmpty
    ? Center(child: Text("No notifications yet"))
    : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    // icon: Icon(Icons.clear_all),
                    label: Text("clear All"),
                    onPressed: clearAllNotifications,
                  ),
                ],
              ),
              ...List.generate(notifications.length, (index) {
                final n = notifications[index];
                final isRead = n['read'] == true;
                final timestamp = DateTime.tryParse(n['timestamp'] ?? '');

                return Dismissible(
                  key: ValueKey(index),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  onDismissed: (_) => deleteNotification(index),
                  child: GestureDetector(
                    onTap: () => markAsRead(index),
                    child: Card(
                      color: isRead ? Colors.white : Color(0xFFF1F8E9),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: isRead
                            ? null
                            : Icon(Icons.brightness_1,
                                size: 10, color: Colors.green),
                        title: Text(
                          n['title'] ?? 'No Title',
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(n['body'] ?? ''),
                        trailing: Text(
                          timestamp != null ? timeago.format(timestamp) : '',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),

    );
  }
}
