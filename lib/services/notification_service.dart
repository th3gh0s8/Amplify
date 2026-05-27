import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'session_manager.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
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

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
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
    String? token = await getFCMToken();
    if (token != null) {
      final phone = await SessionManager.getSession();
      if (phone != null && phone.isNotEmpty) {
        await ApiService().updateFcmToken(phone, token);
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

    // Custom dialog for battery optimization
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      if (context.mounted) {
        final bool? proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text('BACKGROUND ALERTS', 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
            content: const Text(
              'To receive notifications instantly when the app is closed, please allow "Ignore Battery Optimizations" in the next step.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('LATER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ALLOW'),
                ),
              ),
            ],
          ),
        );

        if (proceed == true) {
          await Permission.ignoreBatteryOptimizations.request();
        }
      }
    }
  }

  // Existing logic
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'xpower_notifications',
      'General Notifications',
      channelDescription: 'Notifications for xPower Partners',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

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
      final String title    = item['title']    ?? 'Notification';
      final String message  = item['message']  ?? '';
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
