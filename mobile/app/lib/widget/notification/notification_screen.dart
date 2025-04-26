import 'dart:convert';
// import 'package:app/utils/auth_service.dart';
// import 'package:app/widget/chat_screen.dart';
// import 'package:app/widget/my_task/myTask_details.dart';
import 'package:app/widget/chat_screen.dart';
import 'package:app/widget/task_detail_screen.dart';
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
      body:
          notifications.isEmpty
              ? Center(child: Text("No notifications yet"))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            // icon: Icon(Icons.clear_all),
                            child: Text("clear All"),
                            onPressed: clearAllNotifications,
                          ),
                        ],
                      ),
                      ...notifications.asMap().entries.map((entry) {
                        final n = entry.value;
                        final index = entry.key;
                        final isRead = n['read'] == true;
                        final timestamp = DateTime.tryParse(
                          n['timestamp'] ?? '',
                        );

                        return Dismissible(
                          key: ValueKey(index),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              notifications.removeAt(
                                index,
                              ); // remove from list immediately
                            });
                            _saveNotifications(); // save changes to SharedPreferences
                          },
                          child: GestureDetector(
                            onTap: () {
  markAsRead(index);

  final data = notifications[index];

  if (data['type'] == 'chat' && data['taskId'] != null) {
    final taskId = data['taskId'];

    // Retrieve userId from SharedPreferences or AuthService
    SharedPreferences.getInstance().then((prefs) {
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userId = jsonDecode(userJson)['_id'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              taskId: taskId,
              userId: userId,
            ),
          ),
        );
      } 
    });
  } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(
              taskId: data['taskId'],
            ),
          ),
        );
      }
},

                            child: Card(
                              color:
                                  notifications[index]['read'] == true
                                      ? Colors.white
                                      : Color(0xFFF1F8E9),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading:
                                    notifications[index]['read'] == true
                                        ? null
                                        : Icon(
                                          Icons.brightness_1,
                                          size: 10,
                                          color: Colors.green,
                                        ),
                                title: Text(
                                  notifications[index]['title'] ?? 'No Title',
                                  style: TextStyle(
                                    fontWeight:
                                        notifications[index]['read'] == true
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  notifications[index]['body'] ?? '',
                                ),
                                trailing: Text(
                                  DateTime.tryParse(
                                            notifications[index]['timestamp'] ??
                                                '',
                                          ) !=
                                          null
                                      ? timeago.format(
                                        DateTime.parse(
                                          notifications[index]['timestamp'],
                                        ),
                                      )
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
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
