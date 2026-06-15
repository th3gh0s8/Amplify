import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';
import '../widgets/system_overlay_wrapper.dart';
import '../utils/format_utils.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class MyCustomersPage extends StatefulWidget {
  final String phoneNumber;
  const MyCustomersPage({super.key, required this.phoneNumber});

  @override
  State<MyCustomersPage> createState() => _MyCustomersPageState();
}

class _MyCustomersPageState extends State<MyCustomersPage> {
  final ApiService _apiService = ApiService();
  List<Customer> _customers = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // 'ALL', 'APPROVED', 'PENDING'
  StreamSubscription? _customerSubscription;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _customerSubscription = DatabaseHelper().customerStream.listen((customers) {
      if (mounted) {
        setState(() {
          _customers = customers.map((c) => Customer.fromJson(c)).toList();
        });
      }
    });
  }

  Future<void> _initData() async {
    await _loadCachedCustomers();
    if (mounted) _fetchCustomers();
  }

  @override
  void reassemble() {
    super.reassemble();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _customerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCachedCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_customers_${widget.phoneNumber}');
      if (cached != null && mounted && _customers.isEmpty) {
        final List<dynamic> decoded = json.decode(cached);
        setState(() {
          _customers = decoded.map((e) => Customer.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading cached customers: $e');
    }
  }

  Future<void> _fetchCustomers() async {
    if (!mounted) return;
    try {
      final customersRaw = await _apiService.getCustomers(widget.phoneNumber);
      final customers = customersRaw.map((c) => Customer.fromJson(c)).toList();
      if (mounted) {
        setState(() {
          _customers = customers;
          if (_isLoading) _isLoading = false;
        });
        try {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(
            'cached_customers_${widget.phoneNumber}',
            json.encode(customersRaw),
          );
        } catch (e) {
          debugPrint('Error caching customers: $e');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadSlip(
    int customerId,
    StateSetter setSheetState,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result == null) return;

      setSheetState(() => _isUploading = true);

      File file = File(result.files.single.path!);
      bool success = await _apiService.uploadPaymentSlip(customerId, file);

      if (success) {
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          setState(() {
            _customers[index] = Customer(
              id: _customers[index].id,
              partnerId: _customers[index].partnerId,
              companyName: _customers[index].companyName,
              companyAddress: _customers[index].companyAddress,
              companyNumber: _customers[index].companyNumber,
              adminName: _customers[index].adminName,
              adminNumber: _customers[index].adminNumber,
              companyArea: _customers[index].companyArea,
              companyField: _customers[index].companyField,
              remarks: _customers[index].remarks,
              additionalFeatures: _customers[index].additionalFeatures,
              status: _customers[index].status,
              reference: _customers[index].reference,
              preferredLang: _customers[index].preferredLang,
              packageName: _customers[index].packageName,
              additionalPackages: _customers[index].additionalPackages,
              discount: _customers[index].discount,
              totalCost: _customers[index].totalCost,
              paymentSlip: file.path, // Hot load path
            );
          });
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PAYMENT SLIP UPLOADED')));
        _fetchCustomers(); // Sync local cache in background
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('UPLOAD FAILED')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ERROR: $e')));
    } finally {
      setSheetState(() => _isUploading = false);
    }
  }

  List<Customer> _filteredCustomersList(List<Customer> customers) {
    if (_selectedFilter == 'ALL') return customers;
    return customers.where((c) => c.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SystemOverlayWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text(
            'MY CUSTOMERS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // Render customers directly from state:
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchCustomers,
                color: Colors.black,
                child: _isLoading && _customers.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : _filteredCustomersList(_customers).isEmpty
                    ? _buildEmptyState()
                    : _buildCustomerList(_filteredCustomersList(_customers)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          _buildFilterChip('ALL'),
          const SizedBox(width: 8),
          _buildFilterChip('APPROVED'),
          const SizedBox(width: 8),
          _buildFilterChip('PENDING'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.black.withOpacity(0.05),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isSelected ? Colors.white : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'NO CUSTOMERS CREATED YET';
    if (_selectedFilter != 'ALL') {
      message = 'NO $_selectedFilter CUSTOMERS FOUND';
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black38,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PULL DOWN TO REFRESH',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(List<Customer> list) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final client = list[index];
        bool isApproved = client.status == 'APPROVED';

        return GestureDetector(
          onTap: () => _showCustomerDetails(client),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              client.companyName.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isApproved) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ] else ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.pending,
                              size: 16,
                              color: Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        client.status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isApproved ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  Icons.location_on_outlined,
                  client.companyAddress,
                ),
                _buildDetailItem(
                  Icons.phone_android_outlined,
                  client.companyNumber,
                ),
                _buildDetailItem(Icons.person_outline, client.adminName),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomerDetails(Customer initialClient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final client = _customers.firstWhere(
            (c) => c.id == initialClient.id,
            orElse: () => initialClient,
          );
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                client.companyName.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            if (client.status == 'APPROVED')
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 24,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'STATUS: ${client.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: client.status == 'APPROVED'
                                ? Colors.green
                                : Colors.orange,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle('COMPANY INFORMATION'),
                        _buildDetailRow('Address', client.companyAddress),
                        _buildDetailRow('Phone', client.companyNumber),
                        _buildDetailRow('Area', client.companyArea),
                        _buildDetailRow('Field/Industry', client.companyField),
                        const SizedBox(height: 24),
                        _buildSectionTitle('ADMIN CONTACT'),
                        _buildDetailRow('Name', client.adminName),
                        _buildDetailRow('Phone', client.adminNumber),
                        const SizedBox(height: 24),
                        _buildSectionTitle('PACKAGE DETAILS'),
                        _buildDetailRow('Package', client.packageName ?? 'N/A'),
                        _buildDetailRow(
                          'Additional Modules',
                          client.additionalPackages?.isNotEmpty == true
                              ? client.additionalPackages!
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'Discount',
                          '${client.discount?.toStringAsFixed(0) ?? '0'}%',
                        ),
                        _buildDetailRow(
                          'Total',
                          FormatUtils.formatCurrency(client.totalCost ?? 0),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('ADDITIONAL DETAILS'),
                        _buildDetailRow(
                          'Preferred Language',
                          client.preferredLang,
                        ),
                        _buildDetailRow('Reference Source', client.reference),
                        const SizedBox(height: 16),
                        _buildDetailRow('Remarks', client.remarks),
                        const SizedBox(height: 8),

                        const SizedBox(height: 24),
                        _buildSectionTitle('PAYMENT STATUS'),
                        if (client.paymentSlip != null &&
                            client.paymentSlip!.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'SLIP UPLOADED: ${client.paymentSlip!.split("/").last}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (_isUploading) ...[
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'NO SLIP UPLOADED',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 18,
                              ),
                              label: const Text('UPLOAD PAYMENT SLIP'),
                              onPressed: () =>
                                  _pickAndUploadSlip(client.id!, setSheetState),
                            ),
                          ),
                        ], // ends spread operator
                      ], // ends children list of inner Column
                    ), // ends inner Column
                  ), // ends SingleChildScrollView
                ), // ends Expanded
              ], // ends outer Column children list
            ), // ends outer Column
          ); // ends Container
        }, // ends StatefulBuilder builder function
      ), // ends StatefulBuilder
    ); // ends showModalBottomSheet
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1,
          color: Colors.black38,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
