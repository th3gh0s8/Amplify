import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class AddCustomerPage extends StatefulWidget {
  final String phoneNumber;
  const AddCustomerPage({super.key, required this.phoneNumber});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final TextEditingController _comNameController = TextEditingController();
  final TextEditingController _comAddressController = TextEditingController();
  final TextEditingController _comNumberController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminNumberController = TextEditingController();
  final TextEditingController _comAreaController = TextEditingController();
  final TextEditingController _comFieldController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();

  File? _paymentSlip;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      print('DEBUG: Attempting to pick file...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FILE PICKER ERROR: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_paymentSlip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE UPLOAD PAYMENT SLIP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Clean numbers: remove all non-digits AND leading zero
      String cleanComNumber = _comNumberController.text.replaceAll(RegExp(r'\D'), '');
      if (cleanComNumber.startsWith('0')) cleanComNumber = cleanComNumber.substring(1);

      String cleanAdminNumber = _adminNumberController.text.replaceAll(RegExp(r'\D'), '');
      if (cleanAdminNumber.startsWith('0')) cleanAdminNumber = cleanAdminNumber.substring(1);

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
        additionalFeatures: _featuresController.text,
      );

      // Pass the phone number directly to the API service
      final success = await _apiService.addCustomer(customer, _paymentSlip!, partnerMobile: widget.phoneNumber);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ADD NEW CUSTOMER',
          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
                  _buildTextField(_comNameController, 'COMPANY NAME', Icons.business),
                  const SizedBox(height: 16),
                  _buildPhoneField(_comNumberController, 'COMPANY NUMBER'),
                  const SizedBox(height: 16),
                  _buildTextField(_comAreaController, 'COMPANY AREA', Icons.map),
                  const SizedBox(height: 16),
                  _buildTextField(_comAddressController, 'COMPANY ADDRESS', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildTextField(_comFieldController, 'BUSINESS FIELD', Icons.category),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('OWNER INFORMATION'),
                  const SizedBox(height: 16),
                  _buildTextField(_adminNameController, 'OWNER NAME', Icons.person),
                  const SizedBox(height: 16),
                  _buildPhoneField(_adminNumberController, 'OWNER NUMBER'),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('ADDITIONAL DETAILS'),
                  const SizedBox(height: 16),
                  _buildTextField(_remarksController, 'REMARKS', Icons.notes, maxLines: 3, isOptional: true),
                  const SizedBox(height: 16),
                  _buildTextField(_featuresController, 'ADDITIONAL FEATURES', Icons.add_box, maxLines: 2, isOptional: true),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('PAYMENT SLIP'),
                  const SizedBox(height: 16),
                  _buildFileUploadSection(),
                  
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
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      decoration: InputDecoration(
        labelText: isOptional ? '$label (OPTIONAL)' : label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
        prefixIcon: Icon(icon, size: 18, color: Colors.black),
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            border: Border.all(color: Colors.black.withOpacity(0.05), style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Icon(_paymentSlip == null ? Icons.cloud_upload_outlined : Icons.check_circle_outline, 
                   size: 32, color: _paymentSlip == null ? Colors.black38 : Colors.green),
              const SizedBox(height: 12),
              Text(
                _fileName ?? 'TAP TO UPLOAD PAYMENT SLIP',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w900, 
                  color: _paymentSlip == null ? Colors.black38 : Colors.black
                ),
                textAlign: TextAlign.center,
              ),
              if (_fileName == null) ...[
                const SizedBox(height: 4),
                const Text('PDF, JPG OR PNG (MAX 5MB)', style: TextStyle(fontSize: 9, color: Colors.black26, fontWeight: FontWeight.w700)),
              ]
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    super.dispose();
  }
}
