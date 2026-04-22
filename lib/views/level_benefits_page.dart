import 'package:flutter/material.dart';

class LevelBenefitsPage extends StatelessWidget {
  const LevelBenefitsPage({super.key});

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
          'LEVEL BENEFITS',
          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildLevelDetail(
              'ASSOCIATE',
              'YOUR PARTNERSHIP JOURNEY BEGINS HERE',
              '0 - 99 ACTIVE CLIENTS',
              'Build your client base and start earning.',
              const Color(0xFF9C27B0),
              '10%',
            ),
            const SizedBox(height: 24),
            _buildLevelDetail(
              'ADVISOR',
              'GROW YOUR PORTFOLIO. UNLOCK HIGHER REWARDS.',
              '100+ ACTIVE CLIENTS',
              'Reach 100 active clients to level up.',
              const Color(0xFF2E7D32),
              '15%',
            ),
            const SizedBox(height: 24),
            _buildLevelDetail(
              'MASTER',
              'LEAD THE WAY. MAXIMIZE YOUR EARNINGS.',
              '250+ ACTIVE CLIENTS',
              'Reach 250 active clients to become a Master Partner.',
              const Color(0xFFC62828),
              '20%',
            ),
            const SizedBox(height: 40),
            _buildExplanationSection(),
            const SizedBox(height: 40),
            _buildIncomePotentialTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GROW WITH XPOWER.',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        Text(
          'EARN FOR THE LONG TERM.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black.withOpacity(0.5)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Join our Partner Program and build a predictable, recurring income while helping businesses grow with XPower.',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLevelDetail(String level, String subtitle, String criteria, String description, Color color, String commission) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level,
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  commission,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Colors.black38),
              const SizedBox(width: 8),
              Text(
                criteria,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOW IT WORKS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
        ),
        const SizedBox(height: 16),
        _buildInfoTile(Icons.trending_up, 'UPFRONT COMMISSION', 'Earn on every new sale you close.'),
        _buildInfoTile(Icons.cached, 'RECURRING COMMISSION', 'Earn every month as long as your client stays active.'),
        _buildInfoTile(Icons.history, '24 MONTH DURATION', 'Get paid for up to 24 months for every active client.'),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomePotentialTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INCOME POTENTIAL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
        ),
        const SizedBox(height: 16),
        Text(
          'Based on Monthly Subscription: LKR 2,650 per client',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.3)),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('CLIENTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10))),
              DataColumn(label: Text('ASSOC.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10))),
              DataColumn(label: Text('ADV.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10))),
              DataColumn(label: Text('MASTER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10))),
            ],
            rows: [
              _buildDataRow('100', '26,500', '39,750', '53,000'),
              _buildDataRow('250', '66,250', '99,375', '132,500'),
              _buildDataRow('500', '132,500', '198,750', '265,000'),
              _buildDataRow('1,000', '265,000', '397,500', '530,000'),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(String clients, String assoc, String adv, String master) {
    return DataRow(cells: [
      DataCell(Text(clients, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
      DataCell(Text(assoc, style: const TextStyle(fontSize: 11))),
      DataCell(Text(adv, style: const TextStyle(fontSize: 11))),
      DataCell(Text(master, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
    ]);
  }
}
