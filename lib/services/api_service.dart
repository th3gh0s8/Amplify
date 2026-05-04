import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/partner.dart';
import '../models/invoice.dart';
import '../models/customer.dart';

class ApiService {
  // IMPORTANT: Replace '192.168.1.100' with your Computer's actual IPv4 Address
  // Run 'ipconfig' in CMD to find it.
  // Ensure your Phone and PC are on the same Wi-Fi network.
  // REPLACE THIS with your actual IPv4 from 'ipconfig'
  static const String baseUrl = 'http://192.168.1.150/xpower_api';

  Future<Partner?> getPartner(String mobileNo) async {
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

  Future<bool> verifyOTP(String mobileNo, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_otp.php'),
        body: {
          'mobile_no': mobileNo,
          'otp_code': otpCode,
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

  Future<List<Invoice>> getInvoices(String mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_invoices.php?mobile_no=$mobileNo'),
      );

      if (response.statusCode == 200) {
        print('DEBUG: Invoices Raw Response: ${response.body}');
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Invoice.fromJson(item))
              .toList();
        }
      } else {
        print('DEBUG: Invoices API Error Status: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error (getInvoices): $e');
    }
    return [];
  }

  Future<bool> registerPartner(Partner partner) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register_partner.php'),
        body: {
          'first_name': partner.firstName,
          'last_name': partner.lastName,
          'c_code': partner.cCode.toString(),
          'mobile_no': partner.mobileNo.toString(),
          'email': partner.email,
          'bank_account_no': partner.bankAccountNo.toString(),
          'bank_name': partner.bankName,
          'bank_account_type': partner.bankAccountType,
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

  Future<Map<String, dynamic>?> getDashboardData(String mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_dashboard_data.php?mobile_no=$mobileNo'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPayouts(String mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_payouts.php?mobile_no=$mobileNo'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      print('API Error: $e');
    }
    return [];
  }

  Future<bool> updateBankDetails(String mobileNo, String bankName, String accNo, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_bank_details.php'),
        body: {
          'mobile_no': mobileNo,
          'bank_account_no': accNo,
          'bank_name': bankName,
          'bank_account_type': type,
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

  Future<bool> updateProfile(Partner partner) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_profile.php'),
        body: {
          'mobile_no': partner.mobileNo.toString(),
          'c_code': partner.cCode.toString(),
          'first_name': partner.firstName,
          'last_name': partner.lastName,
          'email': partner.email,
          'bank_account_no': partner.bankAccountNo.toString(),
          'bank_name': partner.bankName,
          'bank_account_type': partner.bankAccountType,
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

  Future<Map<String, dynamic>> requestPayout(String mobileNo, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request_payout.php'),
        body: {
          'mobile_no': mobileNo,
          'amount': amount.toString(),
        },
      );
      return json.decode(response.body);
    } catch (e) {
      print('DEBUG: Payout API Error: $e'); // This will show the actual error in the console
      return {'success': false, 'message': 'Network Error: Check if XAMPP is running and IP is correct'};
    }
  }

  Future<bool> addCustomer(Customer customer, File paymentSlip, {required String partnerMobile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/add_customer.php'));
      
      // Add text fields
      request.fields.addAll({
        'partnerTb': partnerMobile, // Send the mobile number directly
        'com_name': customer.companyName,
        'com_address': customer.companyAddress,
        'com_number': customer.companyNumber,
        'admin_name': customer.adminName,
        'admin_number': customer.adminNumber,
        'com_area': customer.companyArea,
        'com_field': customer.companyField,
        'remarks': customer.remarks,
        'additional_features': customer.additionalFeatures,
      });

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'payment_slip',
        paymentSlip.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('DEBUG: Add Customer Status Code: ${response.statusCode}');
      print('DEBUG: Add Customer Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data['success'] == true;
        } catch (e) {
          print('DEBUG: JSON Parsing Error. Server returned: ${response.body}');
          return false;
        }
      } else {
        print('DEBUG: Server Error Response: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error (Add Customer): $e');
    }
    return false;
  }
}
