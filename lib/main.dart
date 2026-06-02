import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'services/session_manager.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart';
import 'database/database_helper.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final phone = await SessionManager.getSession();
      
      if (phone == null || phone.isEmpty) return true;

      final api = ApiService();
      final dbHelper = DatabaseHelper();
      final notifications = await api.getNotifications(phone);

      if (notifications.isNotEmpty) {
        int? lastSeenId = await dbHelper.getLastNotificationId();
        int baseId = lastSeenId ?? 0;
        
        final newNotifications = notifications.where((n) {
          final id = int.tryParse(n['id'].toString()) ?? 0;
          return id > baseId;
        }).toList();

        if (newNotifications.isNotEmpty) {
          final ns = NotificationService();
          await ns.init();
          
          for (var n in newNotifications) {
            await dbHelper.insertNotification(n);
            final id = int.tryParse(n['id'].toString()) ?? 0;
            await ns.showNotification(
              id: id,
              title: n['title'].toString().toUpperCase(),
              body: n['message'].toString(),
            );
          }
        }
      }
    } catch (e) {
      print('Background task EXCEPTION: $e');
    }
    return true;
  });
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();
  await Workmanager().initialize(callbackDispatcher);
  
  // NOTE: WorkManager periodic tasks have a hard 15m limit from Android.
  // To get faster, we must trigger from the server side (FCM).
  await Workmanager().registerPeriodicTask(
    "xpower_notification_fetch",
    "fetch_notifications_task",
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false, // Relaxed constraint
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _foregroundTimer;

  @override
  void initState() {
    super.initState();
    _startForegroundPolling();
  }

  void _startForegroundPolling() {
    _foregroundTimer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      final phone = await SessionManager.getSession();
      if (phone != null && phone.isNotEmpty) {
        final api = ApiService();
        final dbHelper = DatabaseHelper();
        final notifications = await api.getNotifications(phone);

        if (notifications.isNotEmpty) {
          final lastSeenId = await dbHelper.getLastNotificationId() ?? 0;
          
          final newOnes = notifications.where((n) {
            final id = int.tryParse(n['id'].toString()) ?? 0;
            return id > lastSeenId;
          }).toList();

          if (newOnes.isNotEmpty) {
            for (var n in newOnes) {
              await dbHelper.insertNotification(n);
              final id = int.tryParse(n['id'].toString()) ?? 0;
              await NotificationService().showNotification(
                id: id,
                title: n['title'].toString().toUpperCase(),
                body: n['message'].toString(),
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _foregroundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'xPower Advisor',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: FutureBuilder<String?>(
          future: SessionManager.getSession(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              FlutterNativeSplash.remove();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final service = NotificationService();
              if (!(await service.checkNotificationPermission())) {
                if (context.mounted) {
                  service.requestPermissions(context);
                }
              }
            });

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: Colors.black)),
              );
            }
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
              return DashboardPage(phoneNumber: snapshot.data!);
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.grey[800]!,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        surfaceContainerHighest: Colors.grey[50]!,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -1),
        headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -0.5),
        titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Colors.black),
        bodyLarge: GoogleFonts.manrope(color: Colors.black87, fontSize: 16),
        bodyMedium: GoogleFonts.manrope(color: Colors.black87, fontSize: 14),
        labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 12),
        floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
