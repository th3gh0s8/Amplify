import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/resell_package.dart';

class InvoiceCalculationResult {
  final double packageRate;
  final double modulesRate;
  final double subtotal;
  final double discountAmount;
  final double finalTotal;

  InvoiceCalculationResult({
    required this.packageRate,
    required this.modulesRate,
    required this.subtotal,
    required this.discountAmount,
    required this.finalTotal,
  });
}

class InvoiceService {
  static List<String> getIncludedFeatures(Customer customer) {
    final List<String> features = [];

    final pkg = customer.packageName?.toLowerCase() ?? '';
    if (pkg.contains('website') ||
        pkg.contains('commerce') ||
        pkg.contains('e-commerce')) {
      features.addAll([
        'Online Storefront & Shopping Cart',
        'Payment Gateway Integration',
        'Real-time Product & Stock Synchronization',
        'Customer Profile & Order History Portal',
        'Admin Dashboard & Order Management',
      ]);
    } else {
      features.addAll([
        'Accounting (Profit & Loss, Trial Balance, Balance Sheet)',
        'Stock Management',
        'Credit Management',
        'SMS Management',
        'Profit Analysis',
        'User credit with Privileges',
        'Outstanding Monitoring & Reminding (CRM)',
        'Business analysis with top sales item, customer and sales',
      ]);
    }

    if (customer.additionalPackages != null &&
        customer.additionalPackages!.isNotEmpty) {
      final List<String> modules = customer.additionalPackages!
          .split(',')
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty)
          .toList();
      for (final module in modules) {
        features.add('$module Module Integration');
      }
    }

    if (customer.additionalFeatures.isNotEmpty) {
      for (final line in customer.additionalFeatures.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed.startsWith('PACKAGE:') ||
            trimmed.startsWith('MODULES:') ||
            trimmed.startsWith('TOTAL:')) {
          continue;
        }
        if (!features.contains(trimmed)) {
          features.add(trimmed);
        }
      }
    }

    return features;
  }

  static InvoiceCalculationResult calculateInvoiceDetails(
    Customer customer,
    List<ResellPackage> availablePackages,
  ) {
    double packageRate = 0.0;
    double modulesRate = 0.0;

    final matchingPackage = availablePackages.firstWhere(
      (p) => p.packageName.toLowerCase() == customer.packageName?.toLowerCase(),
      orElse: () => ResellPackage(
        id: 0,
        packageCode: '',
        packageName: customer.packageName ?? '',
        description: '',
        additionalRemarks: '',
        currencyName: 'LKR',
        packageAmount: 0.0,
        billingType: '',
        allowedUsers: 0,
        status: '',
        modules: [],
      ),
    );

    if (matchingPackage.id != 0) {
      packageRate = matchingPackage.packageAmount;
    }

    final List<String> customerModules =
        customer.additionalPackages
            ?.split(',')
            .map((m) => m.trim())
            .where((m) => m.isNotEmpty)
            .toList() ??
        [];

    for (final moduleName in customerModules) {
      final matchingModule = matchingPackage.modules.firstWhere(
        (m) => m.moduleName.toLowerCase() == moduleName.toLowerCase(),
        orElse: () => ResellPackageModule(
          id: 0,
          packageId: 0,
          moduleName: moduleName,
          currencyName: 'LKR',
          modulePrice: 0.0,
          moduleDescription: '',
          moduleType: '',
          status: '',
          moduleGroup: '',
        ),
      );
      modulesRate += matchingModule.modulePrice;
    }

    final double discountPercent = customer.discount ?? 0.0;
    final double finalTotal = customer.totalCost ?? 0.0;

    if (packageRate == 0.0 && modulesRate == 0.0) {
      if (discountPercent > 0 && discountPercent < 100) {
        packageRate = finalTotal / (1 - (discountPercent / 100));
      } else {
        packageRate = finalTotal;
      }
    }

    final double subtotal = packageRate + modulesRate;
    final double discountAmount = subtotal * (discountPercent / 100);

    return InvoiceCalculationResult(
      packageRate: packageRate,
      modulesRate: modulesRate,
      subtotal: subtotal,
      discountAmount: discountAmount,
      finalTotal: finalTotal,
    );
  }

  static Future<void> generateAndShareInvoice(
    Customer customer,
    List<ResellPackage> availablePackages,
  ) async {
    final pdf = pw.Document();

    final calculation = calculateInvoiceDetails(customer, availablePackages);
    final double discountPercent = customer.discount ?? 0.0;

    final List<String> customerModules =
        customer.additionalPackages
            ?.split(',')
            .map((m) => m.trim())
            .where((m) => m.isNotEmpty)
            .toList() ??
        [];

    final dynamicFeatures = getIncludedFeatures(customer);

    final currencyFormatter = NumberFormat("#,##0.00", "en_LK");
    final dateFormatter = DateFormat("dd/MM/yyyy");
    final currentDateStr = dateFormatter.format(DateTime.now());

    pw.Widget buildBulletPoint(String text) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('- ', style: const pw.TextStyle(fontSize: 9)),
            pw.Expanded(
              child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Powersoft Pvt Ltd',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      pw.Text(
                        '544/2, Maradana Road, Colombo 10, Sri Lanka',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Email: support@powersoftt.com',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Web: powersoftt.com',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Hotline: 0722 693 693',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                      color: PdfColors.grey900,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILL TO:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        customer.companyName.toUpperCase(),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      pw.Text(
                        customer.companyAddress,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        customer.adminName,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        customer.companyNumber,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: $currentDateStr',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Invoice No: B-${customer.id ?? "TEMP"}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Table(
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1.2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Rate',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Dis',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          customer.packageName ?? 'Base Package',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          currencyFormatter.format(calculation.packageRate),
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '1 System',
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '${discountPercent.toStringAsFixed(0)}%',
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          currencyFormatter.format(
                            calculation.packageRate *
                                (1 - discountPercent / 100),
                          ),
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (calculation.modulesRate > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Included Features:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              ...dynamicFeatures.map(
                                (feature) => buildBulletPoint(feature),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            currencyFormatter.format(calculation.modulesRate),
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '1',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '${discountPercent.toStringAsFixed(0)}%',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            currencyFormatter.format(
                              calculation.modulesRate *
                                  (1 - discountPercent / 100),
                            ),
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Subtotal: LKR ${currencyFormatter.format(calculation.subtotal)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Discount (${discountPercent.toStringAsFixed(0)}%): LKR ${currencyFormatter.format(calculation.discountAmount)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        height: 0.5,
                        width: 120,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Final Total: LKR ${currencyFormatter.format(calculation.finalTotal)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bank Details',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'POWERSOFT (PVT) LTD',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'COMMERCIAL BANK - GRANDPASS',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'A/C: 100 000 8775',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '- Monthly Maintenance/Service charge 2,650 (Including Server Charges)',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                      pw.Text(
                        '  for five (5) user account each branch',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                      pw.Text(
                        '- Additional user charge will be 300 per month.',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                      pw.Text(
                        '- SMS charge is 1.50 (Tax Included) with no commitments.',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              pw.Center(
                child: pw.Text(
                  'Thank you very much for confidence which you showed in our establishment.\nInvoice generated electronically.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_B-${customer.id ?? "temp"}.pdf',
    );
  }
}
