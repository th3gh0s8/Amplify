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

  // Helper to build a minimal Customer for getIncludedFeatures tests.
  Customer makeCustomer({
    String? packageName,
    String? additionalPackages,
    String additionalFeatures = '',
  }) {
    return Customer(
      partnerId: 1,
      companyName: 'Test Co',
      companyAddress: '1 Test St',
      companyNumber: '0700000000',
      adminName: 'Admin',
      adminNumber: '0700000001',
      companyArea: 'Colombo',
      companyField: 'Retail',
      remarks: '',
      additionalFeatures: additionalFeatures,
      packageName: packageName,
      additionalPackages: additionalPackages,
    );
  }

  group('getIncludedFeatures Unit Tests', () {
    // --- Package name branching ---

    test('null packageName returns accounting feature set', () {
      final customer = makeCustomer(packageName: null);
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(
        features,
        containsAll([
          'Accounting (Profit & Loss, Trial Balance, Balance Sheet)',
          'Stock Management',
          'Credit Management',
          'SMS Management',
          'Profit Analysis',
          'User credit with Privileges',
          'Outstanding Monitoring & Reminding (CRM)',
          'Business analysis with top sales item, customer and sales',
        ]),
      );
      expect(features.length, 8);
    });

    test('packageName containing "website" returns commerce feature set', () {
      final customer = makeCustomer(packageName: 'My Website Package');
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Online Storefront & Shopping Cart'));
      expect(features, contains('Payment Gateway Integration'));
      expect(features, contains('Real-time Product & Stock Synchronization'));
      expect(features, contains('Customer Profile & Order History Portal'));
      expect(features, contains('Admin Dashboard & Order Management'));
      expect(features.length, 5);
    });

    test('packageName "website" is matched case-insensitively', () {
      final customer = makeCustomer(packageName: 'WebSite Pro');
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Online Storefront & Shopping Cart'));
    });

    test('packageName containing "commerce" returns commerce feature set', () {
      final customer = makeCustomer(packageName: 'Commerce Plus');
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Payment Gateway Integration'));
      expect(features, isNot(contains('Stock Management')));
    });

    test('packageName containing "e-commerce" returns commerce feature set', () {
      final customer = makeCustomer(packageName: 'e-commerce Starter');
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Online Storefront & Shopping Cart'));
      expect(features.length, 5);
    });

    test('packageName "E-Commerce Pro" matched case-insensitively', () {
      final customer = makeCustomer(packageName: 'E-Commerce Pro');
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Online Storefront & Shopping Cart'));
    });

    test('unrelated packageName returns accounting feature set', () {
      final customer = makeCustomer(packageName: 'Premium Standard');
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(
        features,
        contains('Accounting (Profit & Loss, Trial Balance, Balance Sheet)'),
      );
      expect(features, isNot(contains('Online Storefront & Shopping Cart')));
    });

    // --- Additional packages ---

    test('null additionalPackages adds no module integration items', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: null,
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features.any((f) => f.endsWith('Module Integration')), isFalse);
    });

    test('empty additionalPackages adds no module integration items', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: '',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features.any((f) => f.endsWith('Module Integration')), isFalse);
    });

    test('single additionalPackages entry is appended with Module Integration suffix', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: 'Barcode Scanner',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Barcode Scanner Module Integration'));
    });

    test('multiple additionalPackages entries are all appended', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: 'Barcode Scanner, SMS Alerts, POS',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Barcode Scanner Module Integration'));
      expect(features, contains('SMS Alerts Module Integration'));
      expect(features, contains('POS Module Integration'));
    });

    test('additionalPackages entries are trimmed before appending', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: '  Barcode Scanner  ,  SMS Alerts  ',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Barcode Scanner Module Integration'));
      expect(features, contains('SMS Alerts Module Integration'));
      // Should not contain untrimmed versions
      expect(
        features,
        isNot(contains('  Barcode Scanner   Module Integration')),
      );
    });

    test('empty entries from additionalPackages commas are filtered out', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: ',Barcode Scanner,,SMS Alerts,',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Barcode Scanner Module Integration'));
      expect(features, contains('SMS Alerts Module Integration'));
      expect(features, isNot(contains(' Module Integration')));
    });

    // --- Additional features ---

    test('empty additionalFeatures adds no extra items', () {
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: '',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features.length, 8); // only base accounting set
    });

    test('valid additionalFeatures lines are appended', () {
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: 'Custom Report\nLive Dashboard',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Custom Report'));
      expect(features, contains('Live Dashboard'));
    });

    test('additionalFeatures lines starting with PACKAGE: are skipped', () {
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: 'PACKAGE: Basic\nCustom Report',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, isNot(contains('PACKAGE: Basic')));
      expect(features, contains('Custom Report'));
    });

    test('additionalFeatures lines starting with MODULES: are skipped', () {
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: 'MODULES: Barcode\nLive Dashboard',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, isNot(contains('MODULES: Barcode')));
      expect(features, contains('Live Dashboard'));
    });

    test('additionalFeatures lines starting with TOTAL: are skipped', () {
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: 'TOTAL: 100000\nLive Dashboard',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, isNot(contains('TOTAL: 100000')));
      expect(features, contains('Live Dashboard'));
    });

    test('blank lines in additionalFeatures are skipped', () {
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: '\n\nCustom Report\n\n',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features, contains('Custom Report'));
      expect(features, isNot(contains('')));
    });

    test('duplicate additionalFeatures line already in base set is not added again', () {
      const duplicateFeature = 'Stock Management';
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: duplicateFeature,
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features.where((f) => f == duplicateFeature).length, 1);
    });

    test('additionalFeatures line trimmed before duplicate check', () {
      // Lines with surrounding whitespace should be trimmed and then deduped.
      const duplicateFeature = 'Stock Management';
      final customer = makeCustomer(
        packageName: null,
        additionalFeatures: '  $duplicateFeature  ',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features.where((f) => f == duplicateFeature).length, 1);
    });

    // --- Combined scenarios ---

    test('commerce package + additional packages + additional features', () {
      final customer = makeCustomer(
        packageName: 'Website Commerce Pro',
        additionalPackages: 'Live Chat, Analytics',
        additionalFeatures: 'Custom Report\nPACKAGE: Ignored\nLive Dashboard',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      // Commerce base
      expect(features, contains('Online Storefront & Shopping Cart'));
      // Additional modules
      expect(features, contains('Live Chat Module Integration'));
      expect(features, contains('Analytics Module Integration'));
      // Additional features
      expect(features, contains('Custom Report'));
      expect(features, contains('Live Dashboard'));
      // Filtered
      expect(features, isNot(contains('PACKAGE: Ignored')));
      // No accounting items
      expect(
        features,
        isNot(contains('Accounting (Profit & Loss, Trial Balance, Balance Sheet)')),
      );
    });

    test('accounting package with no extras returns exactly 8 items', () {
      final customer = makeCustomer(
        packageName: 'Standard Plan',
        additionalPackages: null,
        additionalFeatures: '',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      expect(features.length, 8);
    });

    test('returned list preserves order: base features first, then modules, then additional', () {
      final customer = makeCustomer(
        packageName: null,
        additionalPackages: 'POS',
        additionalFeatures: 'Live Dashboard',
      );
      final features = InvoiceService.getIncludedFeatures(customer);

      // Base accounting items come before module integrations
      final stockIndex = features.indexOf('Stock Management');
      final posIndex = features.indexOf('POS Module Integration');
      final dashIndex = features.indexOf('Live Dashboard');

      expect(stockIndex, lessThan(posIndex));
      expect(posIndex, lessThan(dashIndex));
    });
  });

  group('Invoice Share Integration Tests', () {
    test('generateAndShareInvoice completes successfully', () async {
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
