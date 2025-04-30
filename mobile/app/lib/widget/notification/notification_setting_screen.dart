import 'package:app/widget/notification/notification_switchCard_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool notificationsEnabled = true;
  bool offersEnabled = true;
  bool messagesEnabled = true;
  bool taskUpdatesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      offersEnabled = prefs.getBool('notify_offers') ?? true;
      messagesEnabled = prefs.getBool('notify_messages') ?? true;
      taskUpdatesEnabled = prefs.getBool('notify_task_updates') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('notify_offers', offersEnabled);
    await prefs.setBool('notify_messages', messagesEnabled);
    await prefs.setBool('notify_task_updates', taskUpdatesEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            NotificationSwitchCard(
              title: 'Enable Notifications',
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 12),
            if (notificationsEnabled) ...[
              NotificationSwitchCard(
                title: 'Offers',
                value: offersEnabled,
                onChanged: (value) {
                  setState(() {
                    offersEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              SizedBox(height: 12),
              NotificationSwitchCard(
                title: 'Messages',
                value: messagesEnabled,
                onChanged: (value) {
                  setState(() {
                    messagesEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              SizedBox(height: 12),
              NotificationSwitchCard(
                title: 'Tasks Update',
                value: taskUpdatesEnabled,
                onChanged: (value) {
                  setState(() {
                    taskUpdatesEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
