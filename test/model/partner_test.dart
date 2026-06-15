import 'package:flutter_test/flutter_test.dart';
import 'package:xpower_partners/models/partner.dart';

void main() {
  group('Partner Model Serialization Tests', () {
    test('fromJson mapping verification', () {
      final json = {
        'ID': '1',
        'first_name': 'Kakashi',
        'last_name': 'Hatake',
        'mobile_no': '0779999999',
        'email': 'kakashi@konoha.com',
        'bank_account_no': '98765',
        'bank_name': 'Konoha Bank',
        'bank_ac_branch': 'Main Branch',
        'remarks': 'Copy Ninja',
        'status': 'active',
      };

      final partner = Partner.fromJson(json);

      expect(partner.id, '1');
      expect(partner.firstName, 'Kakashi');
      expect(partner.email, 'kakashi@konoha.com');
    });

    test('toJson serialization output verification', () {
      final partner = Partner(
        id: '1',
        firstName: 'Kakashi',
        lastName: 'Hatake',
        mobileNo: '0779999999',
        email: 'kakashi@konoha.com',
        bankAccountNo: '98765',
        bankName: 'Konoha Bank',
        bankBranch: 'Main Branch',
        remarks: 'Copy Ninja',
        status: 'active',
      );

      final json = partner.toJson();

      expect(json['first_name'], 'Kakashi');
      expect(json['mobile_no'], '0779999999');
    });
  });
}
