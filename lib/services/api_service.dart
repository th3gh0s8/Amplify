import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/partner.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/resell_package.dart';

class ApiService {
  static const String baseUrl = 'https://powersoftt.com/xPowerPartners';
  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Partner?> getProfile(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse('$baseUrl/get_profile.php?mobile_no=$mobileNo&t=$timestamp'),
      );

      print(
        'DEBUG: [getProfile] Fetching data from: ${Uri.parse('$baseUrl/get_profile.php?mobile_no=$mobileNo&t=$timestamp')}',
      );

      if (response.statusCode == 200) {
        print('DEBUG: [getProfile] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        if (data['success']) {
          return Partner.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('API Error (getProfile): $e');
    }
    return null;
  }

  Future<bool> updateProfile(Partner partner) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/update_profile.php'),
        body: json.encode(partner.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('DEBUG: [updateProfile] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        return data['success'];
      }
    } catch (e) {
      print('API Error (updateProfile): $e');
    }
    return false;
  }

  Future<bool> registerPartner(Partner partner) async {
    final res = await registerPartnerResponse(partner);
    return res != null && res['success'] == true;
  }

  Future<Map<String, dynamic>?> registerPartnerResponse(Partner partner) async {
    try {
      // http.post body Map must have String values and no nulls
      final Map<String, String> body = {};
      partner.toJson().forEach((key, value) {
        if (value != null) {
          body[key] = value.toString();
        }
      });

      final response = await client.post(
        Uri.parse('$baseUrl/register_partner.php'),
        body: body,
      );

      if (response.statusCode == 200) {
        print('DEBUG: [registerPartner] Raw Body: ${response.body}');
        return json.decode(response.body);
      }
    } catch (e) {
      print('API Error (registerPartner): $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> verifyOTP(String mobileNo, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/verify_otp.php'),
        body: {'mobile_no': mobileNo, 'otp_code': otp},
      );

      if (response.statusCode == 200) {
        print('DEBUG: [verifyOtp] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        if (data['success'] == true) return data;
      }
    } catch (e) {
      print('API Error (verifyOtp): $e');
    }
    return null;
  }

  Future<Partner?> getPartner(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse('$baseUrl/get_partner.php?mobile_no=$mobileNo&t=$timestamp'),
      );

      print(
        'DEBUG: [getPartner] Fetching data from: ${Uri.parse('$baseUrl/get_partner.php?mobile_no=$mobileNo&t=$timestamp')}',
      );

      if (response.statusCode == 200) {
        print('DEBUG: [getPartner] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        if (data['success']) {
          return Partner.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('API Error (getPartner): $e');
    }
    return null;
  }

  Future<List<ResellPackage>> getPackages() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/get_packages.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((p) => ResellPackage.fromJson(p))
              .toList();
        }
      }
    } catch (e) {
      print('API Error (getPackages): $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getPayouts(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse('$baseUrl/get_payouts.php?mobile_no=$mobileNo&t=$timestamp'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('API Error (getPayouts): $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> requestPayout(
    String mobileNo,
    double amount,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/request_payout.php'),
        body: json.encode({'mobile_no': mobileNo, 'amount': amount}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('API Error (requestPayout): $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDashboardData(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse(
          '$baseUrl/get_dashboard_data.php?mobile_no=$mobileNo&t=$timestamp',
        ),
      );
      if (response.statusCode == 200) {
        print('DEBUG: [getDashboardData] Raw Body: ${response.body}');
        return json.decode(response.body)['data'];
      }
    } catch (e) {
      print('API Error (getDashboardData): $e');
    }
    return null;
  }

  Future<List<Invoice>> getInvoices(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse('$baseUrl/get_invoices.php?mobile_no=$mobileNo&t=$timestamp'),
      );
      if (response.statusCode == 200) {
        print('DEBUG: [getInvoices] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((i) => Invoice.fromJson(i))
              .toList();
        }
      }
    } catch (e) {
      print('API Error (getInvoices): $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCustomers(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse(
          '$baseUrl/get_customers.php?mobile_no=$mobileNo&t=$timestamp',
        ),
      );
      if (response.statusCode == 200) {
        print('DEBUG: [getCustomers] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('API Error (getCustomers): $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getNotifications(String mobileNo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await client.get(
        Uri.parse(
          '$baseUrl/get_notifications.php?mobile_no=$mobileNo&t=$timestamp',
        ),
      );
      if (response.statusCode == 200) {
        print('DEBUG: [getNotifications] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('API Error (getNotifications): $e');
    }
    return [];
  }

  Future<bool> markNotificationsAsRead(String mobileNo) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/mark_notifications_read.php'),
        body: json.encode({'mobile_no': mobileNo}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('DEBUG: [markNotificationsAsRead] Raw Body: ${response.body}');
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error (markNotificationsAsRead): $e');
    }
    return false;
  }

  Future<bool> markNotificationSingleRead(
    String mobileNo,
    int notificationId,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/mark_notification_single_read.php'),
        body: json.encode({
          'mobile_no': mobileNo,
          'notification_id': notificationId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error (markNotificationSingleRead): $e');
    }
    return false;
  }

  Future<bool> addCustomer(
    Customer customer,
    File? paymentSlip, {
    required String partnerMobile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/add_customer.php'),
      );

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
        'reference': customer.reference,
        'preferred_lang': customer.preferredLang,
        'package_name': customer.packageName ?? '',
        'additional_packages': customer.additionalPackages ?? '',
        'discount': customer.discount?.toString() ?? '0',
        'total_cost': customer.totalCost?.toString() ?? '0',
      });
      if (paymentSlip != null) {
        request.files.add(
          await http.MultipartFile.fromPath('payment_slip', paymentSlip.path),
        );
      }

      var streamedResponse = await client.send(request);
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

  Future<bool> updateFcmToken(String mobileNo, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/update_fcm_token.php'),
        body: json.encode({'mobile_no': mobileNo, 'fcm_token': token}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error (Update FCM Token): $e');
    }
    return false;
  }

  Future<bool> deleteFcmToken(String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/delete_fcm_token.php'),
        body: json.encode({'fcm_token': token}),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200 &&
          json.decode(response.body)['success'] == true;
    } catch (e) {
      print('API Error (Delete FCM Token): $e');
    }
    return false;
  }

  Future<bool> uploadPaymentSlip(int customerId, File paymentSlip) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_payment_slip.php'),
      );
      request.fields['customer_id'] = customerId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('payment_slip', paymentSlip.path),
      );
      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error (Upload Payment Slip): $e');
    }
    return false;
  }
}
