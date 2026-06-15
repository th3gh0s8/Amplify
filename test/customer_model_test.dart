import 'package:flutter_test/flutter_test.dart';
import 'package:xpower_partners/models/customer.dart';

void main() {
  group('Customer Model Serialization Tests', () {
    test('fromJson mapping verification', () {
      final json = {
        'ID': '101',
        'partnerTb': '9',
        'com_name': 'Test Corp',
        'com_address': 'Main St 12',
        'com_number': '777888',
        'admin_name': 'John Doe',
        'admin_number': '999000',
        'com_area': 'Central',
        'com_field': 'Tech',
        'remarks': 'None',
        'additional_features': 'Cloud setup',
        'status': 'active',
        'reference': 'From a Friend',
        'preferred_lang': 'English',
        'package_name': 'Starter',
        'additional_packages': 'Analytics',
        'discount': '15.0',
        'total_cost': '45000.0',
        'payment_slip': 'uploads/slips/test.png',
      };

      final customer = Customer.fromJson(json);

      expect(customer.id, 101);
      expect(customer.partnerId, 9);
      expect(customer.companyName, 'Test Corp');
      expect(customer.paymentSlip, 'uploads/slips/test.png');
    });

    test('toJson serialization output verification', () {
      final customer = Customer(
        id: 101,
        partnerId: 9,
        companyName: 'Test Corp',
        companyAddress: 'Main St 12',
        companyNumber: '777888',
        adminName: 'John Doe',
        adminNumber: '999000',
        companyArea: 'Central',
        companyField: 'Tech',
        remarks: 'None',
        additionalFeatures: 'Cloud setup',
        status: 'active',
        reference: 'From a Friend',
        preferredLang: 'English',
        packageName: 'Starter',
        additionalPackages: 'Analytics',
        discount: 15.0,
        totalCost: 45000.0,
        paymentSlip: 'uploads/slips/test.png',
      );

      final json = customer.toJson();

      expect(json['com_name'], 'Test Corp');
      expect(json['partnerTb'], 9);
      expect(json['payment_slip'], 'uploads/slips/test.png');
    });
  });
}
