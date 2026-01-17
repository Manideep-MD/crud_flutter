import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

/// BACKGROUND HANDLER
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage mes) async {
  await Firebase.initializeApp();
  debugPrint('background message ${mes.notification!.title}');
}

/// LOCAL NOTIFICATION INSTANCE
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔴 PUT YOUR FIREBASE SERVER KEY HERE
const String serverKey = 'AAAAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

class NotificationsHandler {
  String? fcmToken;

  /// SETUP FIREBASE PUSH NOTIFICATION
  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    /// Request permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    /// Get FCM token
    fcmToken = await messaging.getToken();
    debugPrint("FCM Token: $fcmToken");
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': fcmToken,
    });

    /// Local notification initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(settings);

    /// Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    /// Notification tap (open app)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked!");
      showNotification(message);
    });
  }

  /// SHOW LOCAL NOTIFICATION
  void showNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You received a message',
      notificationDetails,
    );
  }

  /// 🚀 SEND PUSH NOTIFICATION ON BUTTON CLICK
  Future<void> sendNotification() async {
    if (fcmToken == null) return;
    final body = {
      "to": fcmToken,
      "notification": {
        "title": "New Chat Message",
        "body": "Hello from button click 👋",
      },
      "data": {"type": "chat", "chatId": "123"},
    };
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serverKey",
      },
      body: jsonEncode(body),
    );
  }
}
