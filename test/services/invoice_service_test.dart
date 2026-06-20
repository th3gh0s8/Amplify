import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpower_partners/models/customer.dart';
import 'package:xpower_partners/models/resell_package.dart';
import 'package:xpower_partners/services/invoice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('net.nfet.printing');
  final List<MethodCall> methodLog = [];

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          methodLog.add(methodCall);
          if (methodCall.method == 'sharePdf') {
            return 1;
          }
          return null;
        });
  });

  setUp(() {
    methodLog.clear();
  });

  // Mock Package Data for Happy Path Test
  final mockPackagesList = [
    ResellPackage(
      id: 1,
      packageCode: 'PKG-01',
      packageName: 'Premium Standard',
      description: 'Standard package description',
      additionalRemarks: '',
      currencyName: 'LKR',
      packageAmount: 150000.0,
      billingType: 'One-time',
      allowedUsers: 5,
      status: 'Active',
      modules: [
        ResellPackageModule(
          id: 101,
          packageId: 1,
          moduleName: 'Barcode Scanner',
          currencyName: 'LKR',
          modulePrice: 30000.0,
          moduleDescription: '',
          moduleType: 'Add-on',
          status: 'Active',
          moduleGroup: 'Hardware',
        ),
        ResellPackageModule(
          id: 102,
          packageId: 1,
          moduleName: 'SMS Alerts',
          currencyName: 'LKR',
          modulePrice: 10000.0,
          moduleDescription: '',
          moduleType: 'Add-on',
          status: 'Active',
          moduleGroup: 'Services',
        ),
      ],
    ),
  ];

  group('Invoice Calculations Unit Tests', () {
    test('Best Case: Full match calculations', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'Best Client Ltd',
        companyAddress: '123 Main Road',
        companyNumber: '771234567',
        adminName: 'Alice',
        adminNumber: '771234568',
        companyArea: 'Colombo',
        companyField: 'Retail',
        remarks: 'None',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: 'Barcode Scanner, SMS Alerts',
        discount: 10.0, // 10%
        totalCost: 171000.0, // (150,000 + 30,000 + 10,000) * 0.9 = 171,000
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      expect(result.packageRate, 150000.0);
      expect(result.modulesRate, 40000.0);
      expect(result.subtotal, 190000.0);
      expect(result.discountAmount, 19000.0);
      expect(result.finalTotal, 171000.0);
    });

    test('Worst Case: Empty lists and fallback calculations', () {
      final customer = Customer(
        partnerId: 0,
        companyName: '',
        companyAddress: '',
        companyNumber: '',
        adminName: '',
        adminNumber: '',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: null,
        additionalPackages: null,
        discount: 0.0,
        totalCost: 0.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(customer, []);

      expect(result.packageRate, 0.0);
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 0.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalTotal, 0.0);
    });

    test('Edge Case: Custom discount fallback back-calculations', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'Offline Custom Client',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Custom Package Unlisted',
        additionalPackages: null,
        discount: 25.0, // 25% discount
        totalCost: 75000.0, // Original should be 100,000
      );

      final result = InvoiceService.calculateInvoiceDetails(customer, []);

      expect(result.packageRate, 100000.0); // 75000 / (1 - 0.25)
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 100000.0);
      expect(result.discountAmount, 25000.0);
      expect(result.finalTotal, 75000.0);
    });
  });

  group('Invoice Share Integration Tests', () {
    test('generateAndShareInvoice completes successfully', () async {
      final customer = Customer(
        id: 99,
        partnerId: 1,
        companyName: 'Best Client Ltd',
        companyAddress: '123 Main Road',
        companyNumber: '771234567',
        adminName: 'Alice',
        adminNumber: '771234568',
        companyArea: 'Colombo',
        companyField: 'Retail',
        remarks: 'None',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: 'Barcode Scanner, SMS Alerts',
        discount: 10.0,
        totalCost: 171000.0,
      );

      await expectLater(
        InvoiceService.generateAndShareInvoice(customer, mockPackagesList),
        completes,
      );

      expect(methodLog.length, 1);
      expect(methodLog.first.method, 'sharePdf');
      expect(methodLog.first.arguments['name'], 'invoice_B-99.pdf');
    });
  });
}
