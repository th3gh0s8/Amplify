import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'services/session_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xPower Partners',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: FutureBuilder<String?>(
        future: SessionManager.getSession(),
        builder: (context, snapshot) {
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
