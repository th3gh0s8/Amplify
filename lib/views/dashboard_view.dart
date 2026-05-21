import 'dart:async';
import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'level_benefits_page.dart';
import 'invoice_details_page.dart';
import 'my_customers_page.dart';
import 'notifications_page.dart';
import '../utils/format_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardView extends StatefulWidget {
  final String phoneNumber;
  const DashboardView({super.key, required this.phoneNumber});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _recentInvoices = [];
  Partner? _partner;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll every 60 seconds for new notifications/data
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _loadData(isSilent: true);
    });
  }

  Future<void> _loadData({bool isSilent = false}) async {
    final mobileNo = widget.phoneNumber;
    if (!isSilent && mounted) setState(() => _isLoading = true);
    
    try {
      final data = await _apiService.getDashboardData(mobileNo);
      final invoices = await _apiService.getInvoices(mobileNo);
      final partner = await _apiService.getProfile(mobileNo);
      
      // Check for new notifications to show local alert if in app
      if (data != null && data['unread_notifications'] != null) {
        int currentUnread = int.tryParse(data['unread_notifications'].toString()) ?? 0;
        int prevUnread = int.tryParse(_dashboardData?['unread_notifications']?.toString() ?? '0') ?? 0;
        
        if (currentUnread > prevUnread) {
          _checkAndShowForegroundNotification();
        }
      }

      if (mounted) {
        setState(() {
          _dashboardData = data;
          _recentInvoices = invoices;
          _partner = partner;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !isSilent) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAndShowForegroundNotification() async {
    final notifications = await _apiService.getNotifications(widget.phoneNumber);
    if (notifications.isNotEmpty) {
      final latest = notifications.first;
      final latestId = int.tryParse(latest['id'].toString()) ?? 0;
      
      final prefs = await SharedPreferences.getInstance();
      final lastNotified = prefs.getInt('last_notified_id') ?? 0;
      
      if (latestId > lastNotified) {
        await NotificationService().showNotification(
          id: latestId,
          title: latest['title'].toString().toUpperCase(),
          body: latest['message'].toString(),
        );
        await prefs.setInt('last_notified_id', latestId);
      }
    }
  }

  List<Color> _getLevelColors(String level) {
    switch (level.toUpperCase()) {
      case 'MASTER': return [const Color(0xFFC62828), const Color(0xFF8E0000)]; 
      case 'ADVISOR': return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]; 
      default: return [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)]; 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildLevelProgress(),

            const SizedBox(height: 40),
            const Text(
              'RECENT ACTIVITY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
            ),
            const SizedBox(height: 16),
            _buildInvoicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    bool hasPartner = _partner != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPartner ? 'WELCOME BACK,' : 'WELCOME,',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black.withOpacity(0.4)),
            ),
            const SizedBox(height: 4),
            Text(
              hasPartner ? '${_partner!.firstName} ${_partner!.lastName}'.toUpperCase() : (_partner?.mobileNo ?? widget.phoneNumber),
              style: TextStyle(
                fontSize: hasPartner ? 28 : 20, 
                fontWeight: FontWeight.w900, 
                letterSpacing: hasPartner ? -1 : 0,
                color: hasPartner ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationsPage(mobileNo: widget.phoneNumber)),
          ).then((_) => _loadData()), // Refresh unread count when returning
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: const Icon(Icons.notifications_none_rounded, size: 24, color: Colors.black),
              ),
              if ((int.tryParse(_dashboardData?['unread_notifications']?.toString() ?? '0') ?? 0) > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_dashboardData!['unread_notifications']}',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final data = _dashboardData;
    int totalCustomers = int.tryParse(data?['total_customers']?.toString() ?? '0') ?? 0;
    double pending = double.tryParse(data?['pending_payouts']?.toString() ?? '0') ?? 0;
    String apiLevel = data?['level']?.toString() ?? 'ASSOCIATE';
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'TOTAL EARNED', 
          FormatUtils.formatCurrency(double.tryParse(data?['total_earned']?.toString() ?? '0') ?? 0),
          [const Color(0xFF212121), Colors.black],
          Colors.white,
        ),
        _buildStatCard(
          'PENDING', 
          FormatUtils.formatCurrency(pending),
          [const Color(0xFF424242), const Color(0xFF212121)],
          Colors.white,
        ),
        _buildStatCard(
          'STATUS', 
          apiLevel.toUpperCase(),
          _getLevelColors(apiLevel),
          Colors.white,
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => MyCustomersPage(phoneNumber: widget.phoneNumber))
          ),
          child: _buildStatCard(
            'ACTIVE CLIENTS',
            '$totalCustomers',
            [const Color(0xFF212121), Colors.black],
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgress() {
    final data = _dashboardData;
    int totalCustomers = int.tryParse(data?['total_customers']?.toString() ?? '0') ?? 0;
    
    // Ensure progress is at least visible if there are customers
    double progress = (totalCustomers / 250).clamp(0.01, 1.0); 
    if (totalCustomers == 0) progress = 0.0;

    String apiLevel = data?['level']?.toString() ?? 'ASSOCIATE';
    List<Color> levelColors = _getLevelColors(apiLevel);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LevelBenefitsPage())),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PARTNER GROWTH', 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
              ),
              const Text(
                'VIEW DETAILS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: levelColors),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: levelColors[0].withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LevelMarker(label: 'ASSOCIATE', color: Color(0xFF9C27B0)),
              _LevelMarker(label: 'ADVISOR', color: Color(0xFF2E7D32)),
              _LevelMarker(label: 'MASTER', color: Color(0xFFC62828)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, List<Color> colors, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: textColor.withOpacity(0.5))
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value, 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)
            )
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_recentInvoices.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('NO RECENT ACTIVITY')));
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentInvoices.length > 5 ? 5 : _recentInvoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = _recentInvoices[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => InvoiceDetailsPage(invoice: invoice))
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INV-${invoice.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('${invoice.date.toString().split(' ')[0]}', style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text(FormatUtils.formatCurrency(invoice.comAmount.toDouble()), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LevelMarker extends StatelessWidget {
  final String label;
  final Color color;
  const _LevelMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label, 
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black45)
        ),
      ],
    );
  }
}
