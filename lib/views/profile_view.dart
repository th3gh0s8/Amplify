import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../services/api_service.dart';
import 'edit_profile_page.dart';

class ProfileView extends StatefulWidget {
  final String phoneNumber;
  const ProfileView({super.key, required this.phoneNumber});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _apiService = ApiService();
  Partner? _partner;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPartnerData();
  }

  Future<void> _fetchPartnerData() async {
    setState(() => _isLoading = true);
    try {
      final mobileNo = widget.phoneNumber;
      final partner = await _apiService.getPartner(mobileNo);
      setState(() {
        _partner = partner;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          _buildInfoSection(
            'PERSONAL DATA',
            [
              _buildModernTile(Icons.person, 'FULL NAME', '${_partner?.firstName} ${_partner?.lastName}'.toUpperCase()),
              _buildModernTile(Icons.alternate_email, 'EMAIL ADDRESS', _partner?.email?.toUpperCase() ?? '-'),
              _buildModernTile(Icons.phone_android, 'MOBILE NO', widget.phoneNumber),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'BANKING DETAILS',
            [
              _buildModernTile(Icons.account_balance, 'BANK NAME', _partner?.bankName?.toUpperCase() ?? 'NOT CONFIGURED'),
              _buildModernTile(Icons.tag, 'ACCOUNT NO', (_partner?.bankAccountNo == null || _partner?.bankAccountNo == '0' || _partner?.bankAccountNo == '') ? 'NOT CONFIGURED' : _partner!.bankAccountNo),
              _buildModernTile(Icons.payments, 'BRANCH / TYPE', _partner?.bankAccountType?.toUpperCase() ?? 'NOT CONFIGURED'),
            ],
          ),
          const SizedBox(height: 40),
          _buildActionButton('EDIT PROFILE', Icons.edit_note, () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(partner: _partner!)),
            );
            if (updated == true) _fetchPartnerData();
          }),
          const SizedBox(height: 12),
          _buildActionButton('LOGOUT SESSION', Icons.power_settings_new, () {
             Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }, isDestructive: true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF212121), Colors.black],
              ),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_partner?.firstName} ${_partner?.lastName}'.toUpperCase(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 14, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                'AUTHORIZED PARTNER',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38)
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildModernTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF424242), Color(0xFF212121)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: TextStyle(fontSize: 9, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: isDestructive ? Colors.red : Colors.black),
        label: Text(
          label, 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            letterSpacing: 1, 
            fontSize: 13,
            color: isDestructive ? Colors.red : Colors.black
          )
        ),
        style: TextButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
