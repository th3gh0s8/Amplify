import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xpower_partners/models/invoice.dart';
import '../models/partner.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'level_benefits_page.dart';
import 'invoice_details_page.dart';
import 'my_customers_page.dart';
import 'notifications_page.dart';
import '../database/database_helper.dart';
import '../utils/format_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardView extends StatefulWidget {
  final String phoneNumber;
  final bool isActive;
  const DashboardView({
    super.key,
    required this.phoneNumber,
    required this.isActive,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _recentInvoices = [];
  Partner? _partner;
  bool _isLoading = true;
  Timer? _pollingTimer;
  StreamSubscription? _invoiceSubscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App Resumed: Refreshing Dashboard...');
      _loadData(isSilent: true); // Fetch data without showing loader
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCachedData();
    _loadData();
    DatabaseHelper().refreshNotificationStream();
    _invoiceSubscription = DatabaseHelper().invoiceStream.listen((invoices) {
      if (mounted) {
        setState(() {
          _recentInvoices = invoices;
        });
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadData(isSilent: true);
    DatabaseHelper().refreshNotificationStream();
  }

  @override
  void didUpdateWidget(covariant DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when tab becomes active
    if (widget.isActive && !oldWidget.isActive) {
      _loadData(isSilent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _invoiceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    // 1. Load profile details from SQLite DB
    final cachedPartner = await DatabaseHelper().getPartner(widget.phoneNumber);
    if (mounted && cachedPartner != null) {
      setState(() {
        _partner = cachedPartner;
      });
    }

    // 2. Load stats from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRaw = prefs.getString(
        'cached_dashboard_${widget.phoneNumber}',
      );
      if (cachedRaw != null) {
        final decoded = json.decode(cachedRaw) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _dashboardData = decoded;
            _isLoading =
                false; // We found cached data, so hide initial spinner!
          });
          DatabaseHelper().updateDashboard(decoded);
        }
      }
    } catch (e) {
      debugPrint('Error loading cached dashboard: $e');
    }
  }

  Future<void> _loadData({bool isSilent = false}) async {
    final mobileNo = widget.phoneNumber;
    if (!isSilent && mounted && _dashboardData == null)
      setState(() => _isLoading = true);

    try {
      // 1. Fetch main dashboard and invoices in parallel for speed
      final results = await Future.wait([
        _apiService.getDashboardData(mobileNo),
        _apiService.getInvoices(mobileNo),
      ]);

      final data = results[0] as Map<String, dynamic>?;
      final invoices = results[1] as List<dynamic>? ?? [];

      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cached_dashboard_${widget.phoneNumber}',
          json.encode(data),
        );
      }

      if (mounted) {
        setState(() {
          _dashboardData = data;
          _recentInvoices = invoices;
          if (!isSilent) _isLoading = false;
        });
        DatabaseHelper().updateDashboard(data);
      }

      // 2. Sync profile in background (trigger StreamBuilder)
      _apiService.getProfile(mobileNo).then((partner) async {
        if (partner != null) {
          await DatabaseHelper().insertPartner(partner);
          if (mounted) setState(() => _partner = partner);
        }
      });

      // 2.5 Sync notifications for badge (Memory-based)
      _apiService.getNotifications(mobileNo).then((notifications) {
        DatabaseHelper().updateNotifications(notifications, mobileNo);
      });
    } catch (e) {
      print('Dashboard Load Error: $e');
    } finally {
      if (mounted && !isSilent) setState(() => _isLoading = false);
    }
  }

  List<Color> _getLevelColors(String level) {
    switch (level.toUpperCase()) {
      case 'MASTER':
        return [const Color(0xFFC62828), const Color(0xFF8E0000)];
      case 'ADVISOR':
        return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
      default:
        return [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Partner?>(
      stream: DatabaseHelper().partnerStream,
      initialData: _partner,
      builder: (context, partnerSnapshot) {
        final partner = partnerSnapshot.data;
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: DatabaseHelper().notificationStream,
          initialData: DatabaseHelper().cachedNotifications,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.black,
              child: _isLoading && _dashboardData == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildWelcomeSection(partner),
                          const SizedBox(height: 32),

                          StreamBuilder<Map<String, dynamic>?>(
                            stream: DatabaseHelper().dashboardStream,
                            initialData: _dashboardData,
                            builder: (context, snapshot) {
                              final liveData = snapshot.data;
                              return Column(
                                children: [
                                  _buildStatsGrid(liveData), // Uses live data!
                                  const SizedBox(height: 32),
                                  _buildLevelProgress(
                                    liveData,
                                  ), // Uses live data!
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 40),
                          const Text(
                            'RECENT ACTIVITY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInvoicesList(), // Restored!
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeSection(Partner? partner) {
    bool hasPartner = partner != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPartner ? 'WELCOME BACK,' : 'WELCOME,',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasPartner
                  ? '${partner.firstName} ${partner.lastName}'.toUpperCase()
                  : (partner?.mobileNo ?? widget.phoneNumber),
              style: TextStyle(
                fontSize: hasPartner ? 28 : 20,
                fontWeight: FontWeight.w900,
                letterSpacing: hasPartner ? -1 : 0,
                color: hasPartner ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: DatabaseHelper().notificationStream,
          initialData: DatabaseHelper().cachedNotifications,
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            final unreadCount = data.where((n) => n['is_read'] == 0).length;

            return IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(mobileNo: widget.phoneNumber),
                ),
              ),
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
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic>? data) {
    int totalCustomers =
        int.tryParse(data?['total_customers']?.toString() ?? '0') ?? 0;
    double pending =
        double.tryParse(data?['pending_payouts']?.toString() ?? '0') ?? 0;
    double available =
        double.tryParse(data?['available_balance']?.toString() ?? '0') ?? 0;
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
          'AVAILABLE BALANCE',
          FormatUtils.formatCurrency(available),
          [const Color(0xFF212121), Colors.black],
          Colors.white,
        ),
        _buildStatCard('PENDING', FormatUtils.formatCurrency(pending), [
          const Color(0xFF424242),
          const Color(0xFF212121),
        ], Colors.white),
        _buildStatCard(
          'STATUS',
          apiLevel.toUpperCase(),
          _getLevelColors(apiLevel),
          Colors.white,
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MyCustomersPage(phoneNumber: widget.phoneNumber),
            ),
          ),
          child: _buildStatCard('ACTIVE CLIENTS', '$totalCustomers', [
            const Color(0xFF212121),
            Colors.black,
          ], Colors.white),
        ),
      ],
    );
  }

  Widget _buildLevelProgress(Map<String, dynamic>? data) {
    int totalCustomers =
        int.tryParse(data?['total_customers']?.toString() ?? '0') ?? 0;

    // Ensure progress is at least visible if there are customers
    double progress = (totalCustomers / 250).clamp(0.01, 1.0);
    if (totalCustomers == 0) progress = 0.0;

    String apiLevel = data?['level']?.toString() ?? 'ASSOCIATE';
    List<Color> levelColors = _getLevelColors(apiLevel);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LevelBenefitsPage()),
      ),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PARTNER GROWTH',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.black38,
                ),
              ),
              const Text(
                'VIEW DETAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
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
                      BoxShadow(
                        color: levelColors[0].withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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

  Widget _buildStatCard(
    String label,
    String value,
    List<Color> colors,
    Color textColor,
  ) {
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
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_recentInvoices.isEmpty)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('NO RECENT ACTIVITY'),
        ),
      );

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
              MaterialPageRoute(
                builder: (context) => InvoiceDetailsPage(invoice: invoice),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INV-${invoice.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${invoice.date.toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.3),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    FormatUtils.formatCurrency(invoice.comAmount.toDouble()),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: -0.5,
                    ),
                  ),
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
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
