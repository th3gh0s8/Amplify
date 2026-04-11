import 'package:flutter/material.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LOGIN',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WELCOME',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PLEASE ENTER YOUR MOBILE NUMBER TO CONTINUE',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'MOBILE NUMBER',
                hintText: 'e.g. +1 234 567 890',
                prefixIcon: Icon(Icons.phone, color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                debugPrint('Requesting OTP for: ${_phoneController.text}');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OTPVerificationPage(phoneNumber: _phoneController.text),
                  ),
                );
              },
              child: const Text(
                'GET OTP',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'BY CONTINUING, YOU AGREE TO OUR TERMS',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
