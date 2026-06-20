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

    test('generateAndShareInvoice uses "temp" in filename when customer id is null', () async {
      final customer = Customer(
        // id intentionally omitted (null)
        partnerId: 1,
        companyName: 'No ID Company',
        companyAddress: '55 Side Street',
        companyNumber: '779999999',
        adminName: 'Bob',
        adminNumber: '779999998',
        companyArea: 'Galle',
        companyField: 'Services',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: null,
        discount: 0.0,
        totalCost: 150000.0,
      );

      await expectLater(
        InvoiceService.generateAndShareInvoice(customer, mockPackagesList),
        completes,
      );

      expect(methodLog.length, 1);
      expect(methodLog.first.method, 'sharePdf');
      expect(methodLog.first.arguments['name'], 'invoice_B-temp.pdf');
    });

    test('generateAndShareInvoice with no additional modules completes successfully', () async {
      final customer = Customer(
        id: 42,
        partnerId: 2,
        companyName: 'Solo Package Co',
        companyAddress: '77 Lake Road',
        companyNumber: '760000001',
        adminName: 'Carol',
        adminNumber: '760000002',
        companyArea: 'Kandy',
        companyField: 'Wholesale',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: null,
        discount: 0.0,
        totalCost: 150000.0,
      );

      await expectLater(
        InvoiceService.generateAndShareInvoice(customer, mockPackagesList),
        completes,
      );

      expect(methodLog.length, 1);
      expect(methodLog.first.method, 'sharePdf');
      expect(methodLog.first.arguments['name'], 'invoice_B-42.pdf');
    });
  });

  group('Invoice Calculation Edge Cases', () {
    test('Case-insensitive package name matching', () {
      // Customer uses all-lowercase package name; package list has mixed case
      final customer = Customer(
        partnerId: 1,
        companyName: 'Case Test Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'premium standard', // lowercase variant
        additionalPackages: null,
        discount: 0.0,
        totalCost: 150000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      expect(result.packageRate, 150000.0);
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 150000.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalTotal, 150000.0);
    });

    test('Case-insensitive module name matching', () {
      // Module names in upper case; list has mixed case
      final customer = Customer(
        partnerId: 1,
        companyName: 'Module Case Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: 'BARCODE SCANNER, sms alerts', // mismatched case
        discount: 0.0,
        totalCost: 190000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      expect(result.packageRate, 150000.0);
      expect(result.modulesRate, 40000.0); // 30000 + 10000
      expect(result.subtotal, 190000.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalTotal, 190000.0);
    });

    test('Unrecognized module name contributes zero price', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'Unknown Module Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: 'Barcode Scanner, Unknown Module XYZ',
        discount: 0.0,
        totalCost: 180000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      // Barcode Scanner = 30000, Unknown Module = 0
      expect(result.modulesRate, 30000.0);
      expect(result.packageRate, 150000.0);
      expect(result.subtotal, 180000.0);
      expect(result.discountAmount, 0.0);
    });

    test('Zero discount does not trigger fallback when package is matched', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'No Discount Co',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: null,
        discount: 0.0,
        totalCost: 150000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      expect(result.packageRate, 150000.0);
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 150000.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalTotal, 150000.0);
    });

    test('100% discount triggers fallback else-branch: packageRate equals finalTotal', () {
      // discountPercent == 100 falls into else -> packageRate = finalTotal
      final customer = Customer(
        partnerId: 1,
        companyName: 'Full Discount Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Unlisted Package',
        additionalPackages: null,
        discount: 100.0,
        totalCost: 50000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(customer, []);

      // discountPercent not in (0,100) exclusive, so packageRate = finalTotal
      expect(result.packageRate, 50000.0);
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 50000.0);
      // 50000 * (100/100) = 50000
      expect(result.discountAmount, 50000.0);
      expect(result.finalTotal, 50000.0);
    });

    test('Package with zero amount plus modules does not use fallback', () {
      // A package with id != 0 but packageAmount == 0; modules exist
      final zeroAmountPackages = [
        ResellPackage(
          id: 5,
          packageCode: 'PKG-ZERO',
          packageName: 'Zero Amount Package',
          description: '',
          additionalRemarks: '',
          currencyName: 'LKR',
          packageAmount: 0.0, // zero package price
          billingType: '',
          allowedUsers: 1,
          status: 'Active',
          modules: [
            ResellPackageModule(
              id: 201,
              packageId: 5,
              moduleName: 'Extra Module',
              currencyName: 'LKR',
              modulePrice: 20000.0,
              moduleDescription: '',
              moduleType: '',
              status: 'Active',
              moduleGroup: '',
            ),
          ],
        ),
      ];

      final customer = Customer(
        partnerId: 1,
        companyName: 'Zero Package Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Zero Amount Package',
        additionalPackages: 'Extra Module',
        discount: 0.0,
        totalCost: 20000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        zeroAmountPackages,
      );

      // packageRate=0 but modulesRate=20000 > 0, so fallback should NOT trigger
      expect(result.packageRate, 0.0);
      expect(result.modulesRate, 20000.0);
      expect(result.subtotal, 20000.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalTotal, 20000.0);
    });

    test('additionalPackages string with extra whitespace is parsed correctly', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'Whitespace Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: '  Barcode Scanner  ,   SMS Alerts  ', // extra spaces
        discount: 0.0,
        totalCost: 190000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      expect(result.modulesRate, 40000.0); // both modules matched despite spaces
      expect(result.packageRate, 150000.0);
      expect(result.subtotal, 190000.0);
    });

    test('Correct package matched when multiple packages available', () {
      final multiPackageList = [
        ResellPackage(
          id: 10,
          packageCode: 'PKG-10',
          packageName: 'Basic Plan',
          description: '',
          additionalRemarks: '',
          currencyName: 'LKR',
          packageAmount: 50000.0,
          billingType: '',
          allowedUsers: 2,
          status: 'Active',
          modules: [],
        ),
        ResellPackage(
          id: 11,
          packageCode: 'PKG-11',
          packageName: 'Enterprise Plan',
          description: '',
          additionalRemarks: '',
          currencyName: 'LKR',
          packageAmount: 300000.0,
          billingType: '',
          allowedUsers: 50,
          status: 'Active',
          modules: [],
        ),
        ...mockPackagesList, // includes 'Premium Standard' at 150000
      ];

      final customer = Customer(
        partnerId: 1,
        companyName: 'Multi Package Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Enterprise Plan',
        additionalPackages: null,
        discount: 0.0,
        totalCost: 300000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        multiPackageList,
      );

      expect(result.packageRate, 300000.0); // Enterprise Plan
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 300000.0);
    });

    test('additionalPackages with only whitespace or empty segments are ignored', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'Empty Segments Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: ' ,  , ', // only commas and spaces
        discount: 0.0,
        totalCost: 150000.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      // Empty segments should be filtered out, so no modules added
      expect(result.modulesRate, 0.0);
      expect(result.packageRate, 150000.0);
      expect(result.subtotal, 150000.0);
    });

    test('Discount calculation is correct for fractional discount percentage', () {
      final customer = Customer(
        partnerId: 1,
        companyName: 'Fractional Discount Co',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Premium Standard',
        additionalPackages: null,
        discount: 15.5, // fractional %
        totalCost: 126750.0, // 150000 * (1 - 0.155)
      );

      final result = InvoiceService.calculateInvoiceDetails(
        customer,
        mockPackagesList,
      );

      expect(result.packageRate, 150000.0);
      expect(result.modulesRate, 0.0);
      expect(result.subtotal, 150000.0);
      expect(result.discountAmount, closeTo(23250.0, 0.01));
      expect(result.finalTotal, 126750.0);
    });

    test('InvoiceCalculationResult stores all fields correctly', () {
      final result = InvoiceCalculationResult(
        packageRate: 100.0,
        modulesRate: 200.0,
        subtotal: 300.0,
        discountAmount: 30.0,
        finalTotal: 270.0,
      );

      expect(result.packageRate, 100.0);
      expect(result.modulesRate, 200.0);
      expect(result.subtotal, 300.0);
      expect(result.discountAmount, 30.0);
      expect(result.finalTotal, 270.0);
    });

    test('Fallback back-calculation with boundary discount of just above 0', () {
      // Very small discount (e.g. 0.01%) should use back-calculation formula
      final customer = Customer(
        partnerId: 1,
        companyName: 'Tiny Discount Corp',
        companyAddress: 'Road',
        companyNumber: '0',
        adminName: 'A',
        adminNumber: '0',
        companyArea: '',
        companyField: '',
        remarks: '',
        additionalFeatures: '',
        packageName: 'Unlisted Package',
        additionalPackages: null,
        discount: 0.01, // just above 0, triggers back-calc
        totalCost: 99999.0,
      );

      final result = InvoiceService.calculateInvoiceDetails(customer, []);

      // packageRate = 99999 / (1 - 0.0001) ≈ 99999.0 * 1.0001 ≈ 100009.0
      final expectedRate = 99999.0 / (1 - (0.01 / 100));
      expect(result.packageRate, closeTo(expectedRate, 0.01));
      expect(result.modulesRate, 0.0);
      expect(result.finalTotal, 99999.0);
    });
  });
}
