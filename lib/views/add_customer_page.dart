import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../models/resell_package.dart';

class AddCustomerPage extends StatefulWidget {
  final String phoneNumber;
  const AddCustomerPage({super.key, required this.phoneNumber});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "en_LK");

  String _formatCurrency(double amount) =>
      'LKR ${_currencyFormat.format(amount)}';

  final TextEditingController _comNameController = TextEditingController();
  final TextEditingController _comAddressController = TextEditingController();
  final TextEditingController _comNumberController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminNumberController = TextEditingController();
  final TextEditingController _comAreaController = TextEditingController();
  final TextEditingController _comFieldController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _finalAmountController = TextEditingController();

  String? _selectedReference;
  String _selectedLang = 'English';

  List<ResellPackage> _availablePackages = [];
  ResellPackage? _selectedPackage;
  List<ResellPackageModule> _selectedModules = [];

  double get _packageAmount => _selectedPackage?.packageAmount ?? 0.0;
  double get _modulesAmount =>
      _selectedModules.fold(0, (sum, m) => sum + m.modulePrice);
  double get _totalBeforeDiscount => _packageAmount + _modulesAmount;
  double get _discountValue =>
      _totalBeforeDiscount *
      (double.tryParse(_discountController.text) ?? 0) /
      100;
  double get _calculatedTotal => _totalBeforeDiscount - _discountValue;

  @override
  void initState() {
    super.initState();
    _loadCachedPackages();
    _fetchPackages();
    _discountController.addListener(_updateFinalAmount);
  }

  Future<void> _loadCachedPackages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_packages');
      if (cached != null) {
        final List<dynamic> decoded = json.decode(cached);
        setState(() {
          _availablePackages = decoded
              .map((e) => ResellPackage.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading cached packages: $e');
    }
  }

  Future<void> _fetchPackages() async {
    final packages = await _apiService.getPackages();
    setState(() => _availablePackages = packages);
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'cached_packages',
        json.encode(packages.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error caching packages: $e');
    }
  }

  void _updateFinalAmount() {
    setState(() {
      _finalAmountController.text = _calculatedTotal.toStringAsFixed(2);
    });
  }

  final List<String> _langOptions = [
    'English',
    'Tamil',
    'Sinhala',
    'Arabic',
    'Hindi',
  ];

  final List<String> _referenceOptions = [
    'From a Friend',
    'Social Media Promotion',
    'Customer Called me',
    'From Cold Calling',
    'From Visiting',
    'From an Existing Client',
  ];

  File? _paymentSlip;
  String? _fileName;
  bool _isLoading = false;
  bool _isPaid = false;

  Future<void> _pickFile() async {
    try {
      print('DEBUG: Attempting to pick file...');
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        print('DEBUG: File picked: ${result.files.single.name}');
        setState(() {
          _paymentSlip = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      } else {
        print('DEBUG: File picking cancelled');
      }
    } catch (e) {
      print('DEBUG: File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('FILE PICKER ERROR: $e')));
      }
    }
  }

  void _showDescriptionDialog(
    BuildContext context,
    String title,
    String description,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          description.isNotEmpty ? description : 'NO DESCRIPTION AVAILABLE',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('PACKAGE DETAILS'),
        const SizedBox(height: 16),
        DropdownButtonFormField<ResellPackage>(
          value: _selectedPackage,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'SELECT PACKAGE',
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            prefixIcon: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: Colors.black,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            suffixIcon: _selectedPackage != null
                ? IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue,
                    ),
                    onPressed: () => _showDescriptionDialog(
                      context,
                      _selectedPackage!.packageName,
                      _selectedPackage!.description,
                    ),
                  )
                : null,
          ),
          items: _availablePackages.map((ResellPackage pkg) {
            return DropdownMenuItem<ResellPackage>(
              value: pkg,
              child: Text(
                pkg.packageName.toUpperCase(),
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
          onChanged: (ResellPackage? newValue) {
            setState(() {
              _selectedPackage = newValue;
              _selectedModules = [];
              _updateFinalAmount();
            });
          },
          validator: (value) => value == null ? 'REQUIRED' : null,
        ),
        if (_selectedPackage != null &&
            _selectedPackage!.modules.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'ADDITIONAL MODULES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    ..._selectedPackage!.modules.map(
                      (m) => _buildModuleCheckbox(m),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'DISCOUNT % (OPTIONAL)',
                  labelStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                  prefixIcon: const Icon(
                    Icons.percent,
                    size: 18,
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final discount = double.tryParse(value);
                  if (discount == null || discount < 0 || discount > 100)
                    return '0 - 100%';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _finalAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'FINAL AMOUNT',
                      labelStyle: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                      prefixIcon: const Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: Colors.black,
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  if (double.tryParse(_finalAmountController.text) != null &&
                      (double.tryParse(_finalAmountController.text)! -
                                  _calculatedTotal)
                              .abs() >
                          0.01)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'WARNING: DIFFERENCE OF LKR ${(double.tryParse(_finalAmountController.text)! - _calculatedTotal).abs().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (_selectedPackage != null) ...[
          const SizedBox(height: 32),
          _buildPriceBreakdown(),
        ],
      ],
    );
  }

  Widget _buildModuleCheckbox(ResellPackageModule module) {
    bool isSelected = _selectedModules.any((m) => m.id == module.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedModules.removeWhere((m) => m.id == module.id);
            } else {
              _selectedModules.add(module);
            }
            _updateFinalAmount();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 16,
                color: isSelected ? Colors.white : Colors.black38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.moduleName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: isSelected ? Colors.white70 : Colors.black38,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showDescriptionDialog(
                  context,
                  module.moduleName,
                  module.moduleDescription,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCurrency(module.modulePrice),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white70 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildBreakdownRow('Package', _packageAmount),
          if (_selectedModules.isNotEmpty)
            _buildBreakdownRow('Additional Modules', _modulesAmount),
          _buildBreakdownRow(
            'Discount (${_discountController.text.isEmpty ? "0" : _discountController.text}%)',
            -_discountValue,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white24, height: 1),
          ),
          _buildBreakdownRow('Total', _calculatedTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: isTotal ? 12 : 9,
              fontWeight: FontWeight.w900,
              color: isTotal ? Colors.white : Colors.white38,
              letterSpacing: 1,
            ),
          ),
          Text(
            'LKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 11,
              fontWeight: FontWeight.w900,
              color: isTotal ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isPaid && _paymentSlip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE UPLOAD PAYMENT SLIP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Clean numbers: remove all non-digits AND leading zero
      String cleanComNumber = _comNumberController.text.replaceAll(
        RegExp(r'\D'),
        '',
      );
      if (cleanComNumber.startsWith('0'))
        cleanComNumber = cleanComNumber.substring(1);

      String cleanAdminNumber = _adminNumberController.text.replaceAll(
        RegExp(r'\D'),
        '',
      );
      if (cleanAdminNumber.startsWith('0'))
        cleanAdminNumber = cleanAdminNumber.substring(1);

      final customer = Customer(
        partnerId: 0, // We will use the mobile number instead in the API call
        companyName: _comNameController.text,
        companyAddress: _comAddressController.text,
        companyNumber: cleanComNumber,
        adminName: _adminNameController.text,
        adminNumber: cleanAdminNumber,
        companyArea: _comAreaController.text,
        companyField: _comFieldController.text,
        remarks: _remarksController.text,
        additionalFeatures: _formatFeaturesString(),
        reference: _selectedReference ?? '',
        preferredLang: _selectedLang,
        packageName: _selectedPackage?.packageName,
        additionalPackages: _selectedModules.map((m) => m.moduleName).join(','),
        discount: double.tryParse(_discountController.text) ?? 0.0,
        totalCost: double.tryParse(_finalAmountController.text) ?? 0.0,
      );

      // Pass the phone number directly to the API service
      final success = await _apiService.addCustomer(
        customer,
        _paymentSlip,
        partnerMobile: widget.phoneNumber,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CUSTOMER REGISTERED SUCCESSFULLY')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception('FAILED TO REGISTER CUSTOMER');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ERROR: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatFeaturesString() {
    String features = _featuresController.text;
    if (_selectedPackage != null) {
      String pkgInfo =
          "\n\nPACKAGE: ${_selectedPackage!.packageName}"
          "\nMODULES: ${_selectedModules.map((m) => m.moduleName).join(', ')}"
          "\nTOTAL: LKR ${_calculatedTotal.toStringAsFixed(2)}";
      features += pkgInfo;
    }
    return features;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ADD NEW CUSTOMER',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('COMPANY INFORMATION'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _comNameController,
                      'COMPANY NAME',
                      Icons.business,
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneField(_comNumberController, 'COMPANY NUMBER'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _comAreaController,
                      'COMPANY AREA',
                      Icons.map,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _comAddressController,
                      'COMPANY ADDRESS',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _comFieldController,
                      'BUSINESS FIELD',
                      Icons.category,
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('OWNER INFORMATION'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _adminNameController,
                      'OWNER NAME',
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneField(_adminNumberController, 'OWNER NUMBER'),

                    const SizedBox(height: 32),
                    _buildPackageDetailsSection(),

                    const SizedBox(height: 32),
                    _buildSectionTitle('ADDITIONAL DETAILS'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _remarksController,
                      'REMARKS',
                      Icons.notes,
                      maxLines: 3,
                      isOptional: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _featuresController,
                      'ADDITIONAL FEATURES',
                      Icons.add_box,
                      maxLines: 2,
                      isOptional: true,
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageDropdown(),
                    const SizedBox(height: 16),
                    _buildReferenceDropdown(),

                    Row(
                      children: [
                        Checkbox(
                          value: _isPaid,
                          activeColor: Colors.black,
                          onChanged: (val) =>
                              setState(() => _isPaid = val ?? false),
                        ),
                        const Text(
                          'CUSTOMER HAS PAID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isPaid) ...[
                      _buildFileUploadSection(),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 48),
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.black38,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      decoration: InputDecoration(
        labelText: isOptional ? '$label (OPTIONAL)' : label,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
        prefixIcon: Icon(icon, size: 18, color: Colors.black),
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (isOptional && (value == null || value.isEmpty)) return null;
        return value == null || value.isEmpty ? 'REQUIRED' : null;
      },
    );
  }

  Widget _buildPhoneField(TextEditingController controller, String label) {
    return IntlPhoneField(
      controller: controller,
      initialCountryCode: 'LK',
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      onChanged: (phone) {
        String number = phone.number;
        if (number.startsWith('0')) {
          number = number.substring(1);
          controller.value = controller.value.copyWith(
            text: number,
            selection: TextSelection.collapsed(offset: number.length),
          );
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        counterText: '', // Hide default counter
      ),
      languageCode: "en",
    );
  }

  Widget _buildFileUploadSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _paymentSlip == null
                    ? Icons.cloud_upload_outlined
                    : Icons.check_circle_outline,
                size: 32,
                color: _paymentSlip == null ? Colors.black38 : Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                _fileName ?? 'TAP TO UPLOAD PAYMENT SLIP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _paymentSlip == null ? Colors.black38 : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              if (_fileName == null) ...[
                const SizedBox(height: 4),
                const Text(
                  'PDF, JPG OR PNG (MAX 5MB)',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _submitForm,
        child: const Text(
          'REGISTER CUSTOMER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLang,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'PREFERRED LANGUAGE',
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
        prefixIcon: const Icon(Icons.language, size: 18, color: Colors.black),
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      items: _langOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value.toUpperCase(),
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) setState(() => _selectedLang = newValue);
      },
      validator: (value) => value == null || value.isEmpty ? 'REQUIRED' : null,
    );
  }

  Widget _buildReferenceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedReference,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'HOW DID YOU GET TO KNOW THIS CLIENT?',
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
        prefixIcon: const Icon(
          Icons.help_outline,
          size: 18,
          color: Colors.black,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      items: _referenceOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value.toUpperCase(),
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() => _selectedReference = newValue);
      },
      validator: (value) => value == null || value.isEmpty ? 'REQUIRED' : null,
    );
  }

  @override
  void dispose() {
    _comNameController.dispose();
    _comAddressController.dispose();
    _comNumberController.dispose();
    _adminNameController.dispose();
    _adminNumberController.dispose();
    _comAreaController.dispose();
    _comFieldController.dispose();
    _remarksController.dispose();
    _featuresController.dispose();
    _discountController.dispose();
    _finalAmountController.dispose();
    super.dispose();
  }
}
