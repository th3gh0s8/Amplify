import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/partner.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Partner partner;
  const EditProfilePage({super.key, required this.partner});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _bankNameController;
  late TextEditingController _accNoController;
  late TextEditingController _bankBranchController;
  late TextEditingController _remarksController;

  late TextEditingController _nicController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessTypeController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _taxIdController;
  late TextEditingController _websiteController;
  late String _partnerType;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.partner.firstName,
    );
    _lastNameController = TextEditingController(text: widget.partner.lastName);
    _emailController = TextEditingController(text: widget.partner.email);
    _bankNameController = TextEditingController(text: widget.partner.bankName);
    _accNoController = TextEditingController(
      text:
          (widget.partner.bankAccountNo == '0' ||
              widget.partner.bankAccountNo == '')
          ? ''
          : widget.partner.bankAccountNo,
    );
    _bankBranchController = TextEditingController(
      text: widget.partner.bankBranch,
    );
    _remarksController = TextEditingController(text: widget.partner.remarks);

    _partnerType = widget.partner.partnerType ?? 'freelancer';
    _nicController = TextEditingController(text: widget.partner.nicNumber);
    _businessNameController = TextEditingController(
      text: widget.partner.businessName,
    );
    _businessTypeController = TextEditingController(
      text: widget.partner.businessType,
    );
    _addressController = TextEditingController(
      text: widget.partner.addressLine1,
    );
    _cityController = TextEditingController(text: widget.partner.city);
    _taxIdController = TextEditingController(text: widget.partner.taxId);
    _websiteController = TextEditingController(text: widget.partner.website);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedPartner = Partner(
      id: widget.partner.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobileNo: widget.partner.mobileNo,
      cCode: widget.partner.cCode,
      email: _emailController.text.trim(),
      bankAccountNo: _accNoController.text.trim(),
      bankName: _bankNameController.text.trim(),
      bankBranch: _bankBranchController.text.trim(),
      remarks: _remarksController.text.trim(),
      partnerType: _partnerType,
      nicNumber: _nicController.text.trim(),
      businessName: _businessNameController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      addressLine1: _addressController.text.trim(),
      city: _cityController.text.trim(),
      taxId: _taxIdController.text.trim(),
      website: _websiteController.text.trim(),
    );

    final success = await _apiService.updateProfile(updatedPartner);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PROFILE UPDATED SUCCESSFULLY')),
        );
        Navigator.pop(context, updatedPartner);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('UPDATE FAILED')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text(
            'EDIT PROFILE',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('PERSONAL DETAILS'),
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'FIRST NAME'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'LAST NAME'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'EMAIL'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(v)) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('BUSINESS/FREELANCE DETAILS'),
                DropdownButtonFormField<String>(
                  value: _partnerType,
                  decoration: const InputDecoration(labelText: 'PARTNER TYPE'),
                  items: ['freelancer', 'business']
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _partnerType = v!),
                ),
                const SizedBox(height: 16),
                if (_partnerType == 'freelancer') ...[
                  TextFormField(
                    controller: _nicController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'NIC NUMBER'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _businessNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'BUSINESS NAME',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessTypeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'BUSINESS TYPE',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'ADDRESS'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'CITY'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _taxIdController,
                    decoration: const InputDecoration(labelText: 'TAX ID'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(labelText: 'WEBSITE'),
                  ),
                ],
                const SizedBox(height: 48),
                TextFormField(
                  controller: _bankNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'BANK NAME'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accNoController,
                  decoration: const InputDecoration(
                    labelText: 'ACCOUNT NUMBER',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankBranchController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'BANK BRANCH'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'REMARKS'),
                  maxLines: 2,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.5,
          color: Colors.grey,
        ),
      ),
    );
  }
}
