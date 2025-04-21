import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

/// Handle background messages
@pragma('vm:entry-point') // 👈 Add this line
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 BG Message: ${message.messageId}');
}

/// Create Android notification channel
Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'This channel is used for basic push notifications.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// Show local notification when app is in foreground
void showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;

  localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel', // Make sure it matches the one created
        'Default Notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

/// Store notification locally

Future<void> storeNotificationLocally(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();

  final existingData = prefs.getStringList('notifications') ?? [];
  final now = DateTime.now();

  List<Map<String, dynamic>> existingNotifications = existingData.map((jsonStr) {
    try {
      final n = jsonDecode(jsonStr) as Map<String, dynamic>;
      final ts = DateTime.tryParse(n['timestamp'] ?? '');
      if (ts == null || now.difference(ts).inDays >= 7) return null;
      return n;
    } catch (_) {
      return null;
    }
  }).where((n) => n != null).cast<Map<String, dynamic>>().toList();

  final newNotification = {
    'title': message.notification?.title ?? 'No Title',
    'body': message.notification?.body ?? '',
    'timestamp': now.toIso8601String(),
    'read': false,
    'taskId': message.data['taskId'], // optional for navigation
  };

  existingNotifications.add(newNotification);

  final jsonList = existingNotifications.map((n) => jsonEncode(n)).toList();
  await prefs.setStringList('notifications', jsonList);
}

/// Setup FCM handlers
Future<void> setupFCM() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await createNotificationChannel();

  await localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // Get and print token
  FirebaseMessaging.instance.getToken().then((token) {
    print('📱 FCM Token: $token');
    // TODO: Send token to your backend here
  });

  // Foreground message handler
  // FirebaseMessaging.onMessage.listen((message) {
  //   print('📥 Foreground Message: ${message.notification?.title}');
    
  // });

  // When user taps the notification
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('📲 Notification clicked!');
    // TODO: Navigate to specific screen if needed
  });
  // Store notification locally
  FirebaseMessaging.onMessage.listen((message) async {
    print('📥 Foreground Message: ${message.notification?.title}');
    showLocalNotification(message);
    await storeNotificationLocally(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    print('📲 Notification clicked!');
    await storeNotificationLocally(message);
  });
}

Future<String?> getFcmToken() async {
  return await FirebaseMessaging.instance.getToken();
}
