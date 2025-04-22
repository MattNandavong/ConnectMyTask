import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

/// Handle background messages
@pragma('vm:entry-point') // Required for background execution
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 BG Message: ${message.messageId}');
}

///Android notification channel (required for custom behavior)
Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'This channel is used for basic push notifications.',
    importance: Importance.high,
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

/// Show local notification (foreground mode)
void showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;

  localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );}

/// Save notification to local storage (SharedPreferences)
Future<void> storeNotificationLocally(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();

  final existingData = prefs.getStringList('notifications') ?? [];
  final now = DateTime.now();

  // Keep only notifications within the past 7 days
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
    'taskId': message.data['taskId'], // Optional, helpful for navigation
  };

  existingNotifications.add(newNotification);

  final jsonList = existingNotifications.map((n) => jsonEncode(n)).toList();
  await prefs.setStringList('notifications', jsonList);

  print('🔔 Notification saved locally (${existingNotifications.length} total)');
}

///Set up Firebase Messaging (foreground, background, taps)
Future<void> setupFCM() async {
  // Required to handle messages when app is closed or in background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup local notification system
  await createNotificationChannel();
  await localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // Print FCM token (send this to backend during login/register)
  FirebaseMessaging.instance.getToken().then((token) {
    print('📱 FCM Token: $token');
  });

  // Foreground message: show toast and store locally
  FirebaseMessaging.onMessage.listen((message) async {
    print('Foreground Message: ${message.notification?.title}');
    showLocalNotification(message);
    await storeNotificationLocally(message);

    // Optionally: print chat-related data
    final data = message.data;
    if (data['taskId'] != null && data['text'] != null) {
      print("Chat message detected: ${data['text']}");
    }
  });

  // When user taps on a notification (app already open or recently closed)
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    print(' Notification clicked!');
    await storeNotificationLocally(message);
    // optionally route to specific screen using taskId from data
  });
}

/// Fetch FCM token
Future<String?> getFcmToken() async {
  return await FirebaseMessaging.instance.getToken();
}
