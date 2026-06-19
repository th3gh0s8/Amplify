import 'package:flutter/material.dart';
import 'models/partner.dart';
import 'services/api_service.dart';
import 'otp_verification_page.dart';

class RegistrationPage extends StatefulWidget {
  final String mobileNo;
  final String countryCode;

  const RegistrationPage({
    super.key,
    required this.mobileNo,
    required this.countryCode,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final partner = Partner(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        cCode: widget.countryCode.replaceAll('+', ''),
        mobileNo: widget.mobileNo.replaceAll(RegExp(r'\D'), ''),
        email: _emailController.text.trim(),
        bankAccountNo: '0',
        bankName: '',
        bankBranch: '',
        remarks: '',
      );

      final response = await _apiService.registerPartnerResponse(partner);

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('REGISTRATION SUCCESSFUL')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(
                phoneNumber: partner.mobileNo,
                displayPhoneNumber: '${widget.countryCode} ${widget.mobileNo}',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          String errorMsg = response?['message'] ?? 'REGISTRATION FAILED';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg.toUpperCase())));
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'JOIN XPOWER',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'REGISTERING: ${widget.countryCode} ${widget.mobileNo}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 48),
                _buildField('FIRST NAME', _firstNameController),
                const SizedBox(height: 24),
                _buildField('LAST NAME', _lastNameController),
                const SizedBox(height: 24),
                _buildField(
                  'EMAIL ADDRESS',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'FIELD REQUIRED';
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(v)) return 'INVALID EMAIL FORMAT';
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('INITIALIZE PARTNERSHIP'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          validator: validator ?? (v) => v!.isEmpty ? 'FIELD REQUIRED' : null,
        ),
      ],
    );
  }
}
