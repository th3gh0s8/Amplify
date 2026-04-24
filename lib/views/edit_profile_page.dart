import 'package:flutter/material.dart';
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
  late String _accType;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.partner.firstName);
    _lastNameController = TextEditingController(text: widget.partner.lastName);
    _emailController = TextEditingController(text: widget.partner.email);
    _bankNameController = TextEditingController(text: widget.partner.bankName);
    _accNoController = TextEditingController(text: (widget.partner.bankAccountNo == '0' || widget.partner.bankAccountNo == '') ? '' : widget.partner.bankAccountNo);
    _accType = (widget.partner.bankAccountType == null || widget.partner.bankAccountType == '') ? 'Savings' : widget.partner.bankAccountType;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedPartner = Partner(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobileNo: widget.partner.mobileNo,
      cCode: widget.partner.cCode,
      email: _emailController.text.trim(),
      bankAccountNo: _accNoController.text.trim(),
      bankName: _bankNameController.text.trim(),
      bankAccountType: _accType,
    );

    final success = await _apiService.updateProfile(updatedPartner);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PROFILE UPDATED SUCCESSFULLY')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPDATE FAILED')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT PROFILE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
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
                decoration: const InputDecoration(labelText: 'FIRST NAME'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'LAST NAME'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'EMAIL'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v)) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('BANK DETAILS'),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'BANK NAME'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accNoController,
                decoration: const InputDecoration(labelText: 'ACCOUNT NUMBER'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _accType,
                decoration: const InputDecoration(labelText: 'ACCOUNT TYPE'),
                items: ['Savings', 'Current'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _accType = v!),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.grey)),
    );
  }
}
