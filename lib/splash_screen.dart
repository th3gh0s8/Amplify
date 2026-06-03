import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'services/session_manager.dart';
import 'services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for the splash duration
    await Future.delayed(const Duration(seconds: 3));
    
    // Check session
    final phone = await SessionManager.getSession();
    
    if (mounted) {
      // Handle notification permissions check before navigating
      final service = NotificationService();
      if (!(await service.checkNotificationPermission())) {
        if (mounted) {
          await service.requestPermissions(context);
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => (phone != null && phone.isNotEmpty)
                ? DashboardPage(phoneNumber: phone)
                : const LoginPage(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash.jpeg',
                width: 250,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
