import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/partner.dart';
import '../models/invoice.dart';

class ApiService {
  // Use 10.0.2.2 if you are on Android Emulator to refer to your PC's localhost
  // Use your PC's LAN IP (e.g., 192.168.1.5) if testing on a real device
  static const String baseUrl = 'http://10.0.2.2/xpower_api';

  Future<Partner?> getPartner(int mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_partner.php?mobile_no=$mobileNo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Partner.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  Future<bool> verifyOTP(int mobileNo, int otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_otp.php'),
        body: {
          'mobile_no': mobileNo.toString(),
          'otp_code': otpCode.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error: $e');
    }
    return false;
  }

  Future<List<Invoice>> getInvoices(int mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_invoices.php?mobile_no=$mobileNo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Invoice.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    return [];
  }
}
