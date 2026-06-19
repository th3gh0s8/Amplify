import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'session_manager.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
  try {
    final notification = message.notification;
    if (notification != null) {
      final title = notification.title ?? '';
      final body = notification.body ?? '';
      if (title.isNotEmpty || body.isNotEmpty) {
        final key =
            '${title.toLowerCase().trim()}|${body.toLowerCase().trim()}';
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList('recent_shown_notifications') ?? [];
        if (!list.contains(key)) {
          list.add(key);
          if (list.length > 20) list.removeAt(0); // keep cache size small
          await prefs.setStringList('recent_shown_notifications', list);
          debugPrint('[FCM Background] Stored notification key: $key');
        }
      }
    }
  } catch (e) {
    debugPrint('Error in background handler: $e');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    // FCM Setup
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      if (message.notification != null) {
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'NOTIFICATION',
          body: message.notification!.body ?? '',
        );
      }
    });

    // Token
    await syncToken();
  }

  Future<void> syncToken() async {
    String? token = await getFCMToken();
    if (token != null) {
      final phone = await SessionManager.getSession();
      if (phone != null && phone.isNotEmpty) {
        await ApiService().updateFcmToken(phone, token);
        debugPrint('FCM Token synced for $phone');
      }
    }
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint('=========================================');
        debugPrint('FCM TOKEN: $token');
        debugPrint('=========================================');
      } else {
        debugPrint('FCM TOKEN: NULL (Check Firebase Console setup)');
      }
      return token;
    } catch (e) {
      debugPrint('FCM TOKEN ERROR: $e');
      return null;
    }
  }

  Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> requestPermissions(BuildContext context) async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Existing logic
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final key = '${title.toLowerCase().trim()}|${body.toLowerCase().trim()}';
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('recent_shown_notifications') ?? [];

      if (list.contains(key)) {
        debugPrint(
          '[NotificationService] Suppressing duplicate notification: $title',
        );
        return; // Stop execution to suppress duplication
      }

      list.add(key);
      if (list.length > 20) list.removeAt(0);
      await prefs.setStringList('recent_shown_notifications', list);
    } catch (e) {
      debugPrint('Error checking duplicate in showNotification: $e');
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'xpower_notifications_v2',
          'General Notifications',
          channelDescription: 'Notifications for xPower Partners',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }

  // PM's logic integrated
  Future<void> fireServerNotifications(List<dynamic> items) async {
    int idCounter = 300;
    for (final dynamic item in items) {
      final String title = item['title'] ?? 'Notification';
      final String message = item['message'] ?? '';
      await showNotification(id: idCounter++, title: title, body: message);
      debugPrint('[Notifications] Notified: $title');
    }
  }

  Future<void> notifyNewAnnouncements(List<dynamic> announcements) async {
    if (announcements.isEmpty) return;
    int idCounter = 200;
    for (final dynamic item in announcements) {
      await showNotification(
        id: idCounter++,
        title: '\U0001f4e2 ${item['title'] ?? 'New Announcement'}',
        body: item['announcment'] ?? '',
      );
    }
  }
}
