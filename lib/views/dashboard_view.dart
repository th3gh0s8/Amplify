import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mobileNo = int.tryParse(widget.phoneNumber.replaceAll(RegExp(r'\D'), ''));
    if (mobileNo != null) {
      final data = await _apiService.getDashboardData(mobileNo);
      final invoices = await _apiService.getInvoices(mobileNo);
      setState(() {
        _dashboardData = data;
        _recentInvoices = invoices;
        _isLoading = false;
      });
    }
  }

  String _calculateLevel(int customers) {
    if (customers >= 250) return 'MASTER';
    if (customers >= 100) return 'ADVISOR';
    return 'ASSOCIATE';
  }

  List<Color> _getLevelColors(String level) {
    switch (level) {
      case 'MASTER': return [const Color(0xFFC62828), const Color(0xFF8E0000)]; // Ruby
      case 'ADVISOR': return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]; // Emerald
      default: return [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)]; // Amethyst
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK,',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black.withOpacity(0.4)),
        ),
        const SizedBox(height: 4),
        Text(
          widget.phoneNumber,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    int totalInvoices = int.tryParse(_dashboardData?['total_invoices']?.toString() ?? '0') ?? 0;
    String currentLevel = _calculateLevel(totalInvoices);
    
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
          'LKR ${_dashboardData?['total_earned'] ?? '0.00'}',
          [const Color(0xFF424242), const Color(0xFF212121)],
          Colors.white,
        ),
        _buildStatCard(
          'PENDING', 
          'LKR ${_dashboardData?['pending_payouts'] ?? '0.00'}',
          [const Color(0xFF757575), const Color(0xFF424242)],
          Colors.white,
        ),
        _buildStatCard(
          'STATUS', 
          currentLevel,
          _getLevelColors(currentLevel),
          Colors.white,
        ),
        _buildStatCard(
          'TOTAL INVOICES',
          '$totalInvoices',
          [const Color(0xFF424242), const Color(0xFF212121)],
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildLevelProgress() {
    int totalInvoices = int.tryParse(_dashboardData?['total_invoices']?.toString() ?? '0') ?? 0;
    double progress = (totalInvoices / 250).clamp(0.0, 1.0); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PARTNER GROWTH',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF2E7D32), Color(0xFFC62828)],
                    stops: [0.0, 0.4, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              color: textColor.withOpacity(0.5)
            )
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w900, 
                color: textColor,
                letterSpacing: -0.5
              )
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
        return Container(
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
                  Text(
                    'INV-${invoice.id}', 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${invoice.date}', 
                    style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w700)
                  ),
                ],
              ),
              Text(
                'LKR ${invoice.comAmount}', 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5)
              ),
            ],
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
