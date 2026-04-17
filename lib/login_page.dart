import 'package:flutter/material.dart';
import 'otp_verification_page.dart';
import 'database/database_helper.dart';
import 'models/partner.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final phoneStr = _phoneController.text.trim();
    if (phoneStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER MOBILE NUMBER')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Basic validation: check if it's a number
      final mobileNo = int.tryParse(phoneStr.replaceAll(RegExp(r'\D'), ''));
      if (mobileNo == null) {
        throw Exception('INVALID MOBILE NUMBER');
      }

      final partner = await _dbHelper.getPartner(mobileNo);

      if (partner != null) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(phoneNumber: phoneStr),
            ),
          );
        }
      } else {
        // If partner doesn't exist, we might want to register them or show error
        // For now, let's show an error or provide a way to "Register" (seed data)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PARTNER NOT FOUND. PLEASE REGISTER.')),
          );
          // Optional: navigate to registration
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                hintText: 'e.g. 1234567890',
                prefixIcon: Icon(Icons.phone, color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
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
