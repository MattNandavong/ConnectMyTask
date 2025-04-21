import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

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
          AndroidFlutterLocalNotificationsPlugin>()
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
  FirebaseMessaging.onMessage.listen((message) {
    print('📥 Foreground Message: ${message.notification?.title}');
    showLocalNotification(message);
  });

  // When user taps the notification
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('📲 Notification clicked!');
    // TODO: Navigate to specific screen if needed
  });
}

Future<String?> getFcmToken() async {
  return await FirebaseMessaging.instance.getToken();
}
