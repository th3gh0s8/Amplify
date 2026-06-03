import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/session_manager.dart';
import '../database/database_helper.dart';
import '../login_page.dart';
import 'edit_profile_page.dart';

class ProfileView extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onProfileUpdated;
  const ProfileView({super.key, required this.phoneNumber, this.onProfileUpdated});

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Load from local cache immediately
    final cached = await DatabaseHelper().getPartner(widget.phoneNumber);
    if (mounted && cached != null) {
      setState(() {
        _partner = cached;
        _isLoading = false; // Show cached data immediately
      });
    }
    // 2. Fetch fresh data from API
    _fetchPartnerData();
  }

  Future<void> _fetchPartnerData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final mobileNo = widget.phoneNumber;
      final partner = await _apiService.getProfile(mobileNo);
      
      if (partner != null) {
        await DatabaseHelper().insertPartner(partner);
      }

      if (mounted) {
        setState(() {
          _partner = partner;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Profile Fetch Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Partner?>(
      stream: DatabaseHelper().partnerStream,
      initialData: _partner,
      builder: (context, snapshot) {
        final partner = snapshot.data;
        if (_isLoading && partner == null) return const Center(child: CircularProgressIndicator(color: Colors.black));

        return RefreshIndicator(
          onRefresh: _fetchPartnerData,
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(partner),
                const SizedBox(height: 40),
                _buildInfoSection(
                  'PERSONAL DATA',
                  [
                    _buildModernTile(Icons.person, 'FULL NAME', '${partner?.firstName ?? ''} ${partner?.lastName ?? ''}'.toUpperCase()),
                    _buildModernTile(Icons.alternate_email, 'EMAIL ADDRESS', partner?.email.toUpperCase() ?? '-'),
                    _buildModernTile(Icons.phone_android, 'MOBILE NO', partner?.mobileNo ?? widget.phoneNumber),
                  ],
                ),
                const SizedBox(height: 24),
                if (partner?.partnerType != null) ...[
                  _buildInfoSection(
                    'BUSINESS / FREELANCE DETAILS',
                    [
                      _buildModernTile(Icons.category, 'PARTNER TYPE', partner!.partnerType!.toUpperCase()),
                      if (partner.partnerType == 'freelancer' && partner.nicNumber != null && partner.nicNumber!.isNotEmpty)
                        _buildModernTile(Icons.badge, 'NIC NUMBER', partner.nicNumber!.toUpperCase()),
                      if (partner.partnerType == 'business') ...[
                        _buildModernTile(Icons.business, 'BUSINESS NAME', partner.businessName?.toUpperCase() ?? '-'),
                        _buildModernTile(Icons.settings, 'BUSINESS TYPE', partner.businessType?.toUpperCase() ?? '-'),
                        _buildModernTile(Icons.location_city, 'CITY', partner.city?.toUpperCase() ?? '-'),
                        _buildModernTile(Icons.public, 'WEBSITE', partner.website ?? '-'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                _buildInfoSection(
                  'BANKING DETAILS',
                  [
                    _buildModernTile(Icons.account_balance, 'BANK NAME', partner?.bankName.toUpperCase() ?? 'NOT CONFIGURED'),
                    _buildModernTile(Icons.tag, 'ACCOUNT NO', (partner?.bankAccountNo == null || partner?.bankAccountNo == '0' || partner?.bankAccountNo == '') ? 'NOT CONFIGURED' : partner!.bankAccountNo),
                    _buildModernTile(Icons.payments, 'BRANCH / TYPE', partner?.bankBranch.toUpperCase() ?? 'NOT CONFIGURED'),
                  ],
                ),
                const SizedBox(height: 24),
                if (partner?.remarks != null && partner!.remarks.isNotEmpty && partner.remarks != '-') ...[
                  _buildInfoSection(
                    'ACCOUNT REMARKS',
                    [
                      _buildModernTile(Icons.notes, 'REMARKS', partner.remarks.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 16),
                _buildActionButton('EDIT PROFILE', Icons.edit_note, () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage(partner: partner!)),
                  );
                  
                  if (result != null) {
                    _fetchPartnerData();
                    if (widget.onProfileUpdated != null) widget.onProfileUpdated!();
                  }
                }),
                const SizedBox(height: 12),
                _buildActionButton('LOGOUT', Icons.power_settings_new, () async {
                   final token = await NotificationService().getFCMToken();
                   if (token != null) {
                     await _apiService.deleteFcmToken(token);
                   }
                   await SessionManager.clearSession();

                   if (mounted) {
                     Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (context) => const LoginPage()),
                       (route) => false
                     );
                   }
                }, isDestructive: true),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Partner? partner) {
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
          '${partner?.firstName ?? ''} ${partner?.lastName ?? ''}'.toUpperCase(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 14, color: partner?.status == 'authorized' ? Colors.blue : (partner?.status == 'pending' ? Colors.orange : Colors.red)),
              const SizedBox(width: 6),
              Text(
                (partner?.status == 'authorized' 
                    ? '${partner?.status} PARTNER' 
                    : (partner?.status == 'pending' ? 'PENDING VERIFICATION' : (partner?.status ?? 'PENDING'))).toUpperCase(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
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
