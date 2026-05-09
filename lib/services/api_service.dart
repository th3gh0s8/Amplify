import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/partner.dart';
import '../models/invoice.dart';
import '../models/customer.dart';

class ApiService {
  // Production URL
  static const String baseUrl = 'https://powersoftt.com/xPowerPartners';

  Future<Partner?> getPartner(String mobileNo) async {
    String cleanNo = mobileNo.replaceAll(RegExp(r'\D'), '');
    if (cleanNo.startsWith('94')) cleanNo = cleanNo.substring(2);
    if (cleanNo.startsWith('0')) cleanNo = cleanNo.substring(1);

    final url = '$baseUrl/get_partner.php?mobile_no=$cleanNo&t=${DateTime.now().millisecondsSinceEpoch}';
    print('DEBUG: [getPartner] Requesting fresh OTP from: $url');
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      print('DEBUG: [getPartner] Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Partner.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('DEBUG: [getPartner] CONNECTION FAILED: $e');
    }
    return null;
  }

  Future<Partner?> getProfile(String mobileNo) async {
    String cleanNo = mobileNo.replaceAll(RegExp(r'\D'), '');
    if (cleanNo.startsWith('94')) cleanNo = cleanNo.substring(2);
    if (cleanNo.startsWith('0')) cleanNo = cleanNo.substring(1);

    final url = '$baseUrl/get_profile.php?mobile_no=$cleanNo&t=${DateTime.now().millisecondsSinceEpoch}';
    print('DEBUG: [getProfile] Fetching data from: $url');

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      print('DEBUG: [getProfile] Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Partner.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('DEBUG: [getProfile] Error: $e');
    }
    return null;
  }

  Future<bool> verifyOTP(String mobileNo, String otpCode) async {
    try {
      final body = {'mobile_no': mobileNo, 'otp_code': otpCode};
      final response = await http.post(Uri.parse('$baseUrl/verify_otp.php'), body: body);
      print('DEBUG: [verifyOTP] Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('DEBUG: [verifyOTP] Error: $e');
    }
    return false;
  }

  Future<List<Invoice>> getInvoices(String mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_invoices.php?mobile_no=$mobileNo&t=${DateTime.now().millisecondsSinceEpoch}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((item) => Invoice.fromJson(item)).toList();
        }
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
          'bank_account_type': partner.bankBranch,
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
        Uri.parse('$baseUrl/get_dashboard_data.php?mobile_no=$mobileNo&t=${DateTime.now().millisecondsSinceEpoch}'),
      );
      print('DEBUG: [getDashboardData] Raw Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('API Error (getDashboardData): $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPayouts(String mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_payouts.php?mobile_no=$mobileNo&t=${DateTime.now().millisecondsSinceEpoch}'),
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
          'bank_account_type': partner.bankBranch,
          'remarks': partner.remarks,
          'partner_type': partner.partnerType ?? '',
          'nic_number': partner.nicNumber ?? '',
          'business_name': partner.businessName ?? '',
          'business_type': partner.businessType ?? '',
          'address_line1': partner.addressLine1 ?? '',
          'city': partner.city ?? '',
          'tax_id': partner.taxId ?? '',
          'website': partner.website ?? '',
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

  Future<List<Customer>> getCustomers(String mobileNo) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_customers.php?mobile_no=$mobileNo&t=${DateTime.now().millisecondsSinceEpoch}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((i) => Customer.fromJson(i)).toList();
        }
      }
    } catch (e) {
      print('DEBUG: [getCustomers] Error: $e');
    }
    return [];
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
      print('DEBUG: Payout API Error: $e');
      return {'success': false, 'message': 'Network Error'};
    }
  }

  Future<bool> addCustomer(Customer customer, File paymentSlip, {required String partnerMobile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/add_customer.php'));
      
      request.fields.addAll({
        'partnerTb': partnerMobile,
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

      request.files.add(await http.MultipartFile.fromPath(
        'payment_slip',
        paymentSlip.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

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
