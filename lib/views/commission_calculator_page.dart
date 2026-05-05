import 'package:flutter/material.dart';

class CommissionCalculatorPage extends StatefulWidget {
  const CommissionCalculatorPage({super.key});

  @override
  State<CommissionCalculatorPage> createState() => _CommissionCalculatorPageState();
}

class _CommissionCalculatorPageState extends State<CommissionCalculatorPage> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _avgValueController = TextEditingController(text: "10000"); // Default avg sale value

  double _estimatedMonthly = 0.0;
  String _projectedLevel = 'ASSOCIATE';
  double _currentRate = 10.0;

  void _calculate() {
    int customers = int.tryParse(_customerController.text) ?? 0;
    double avgValue = double.tryParse(_avgValueController.text) ?? 0.0;

    setState(() {
      if (customers >= 250) {
        _projectedLevel = 'MASTER';
        _currentRate = 20.0;
      } else if (customers >= 100) {
        _projectedLevel = 'ADVISOR';
        _currentRate = 15.0;
      } else {
        _projectedLevel = 'ASSOCIATE';
        _currentRate = 10.0;
      }

      _estimatedMonthly = customers * avgValue * (_currentRate / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EARNINGS CALCULATOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESTIMATE YOUR RECURRING INCOME',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
            const SizedBox(height: 8),
            const Text('Enter your target metrics to see your potential monthly earnings.'),
            const SizedBox(height: 32),
            _buildInputCard(),
            const SizedBox(height: 32),
            _buildResultCard(),
            const SizedBox(height: 32),
            _buildLevelInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _customerController,
            label: 'NUMBER OF ACTIVE CLIENTS',
            hint: 'e.g. 150',
            icon: Icons.people_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _avgValueController,
            label: 'AVERAGE MONTHLY SALE (LKR)',
            hint: 'e.g. 10000',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('CALCULATE POTENTIAL'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black45)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.black),
          ),
          onChanged: (_) => _calculate(),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getLevelColors(_projectedLevel),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _getLevelColors(_projectedLevel)[0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'PROJECTED $_projectedLevel STATUS',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            'LKR ${_estimatedMonthly.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          const Text(
            'ESTIMATED MONTHLY RECURRING',
            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentRate.toInt()}% COMMISSION RATE',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIER SUMMARY',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
        ),
        const SizedBox(height: 16),
        _buildTierRow('ASSOCIATE', '0-99 Clients', '10%', const Color(0xFF9C27B0)),
        _buildTierRow('ADVISOR', '100+ Clients', '15%', const Color(0xFF2E7D32)),
        _buildTierRow('MASTER', '250+ Clients', '20%', const Color(0xFFC62828)),
      ],
    );
  }

  Widget _buildTierRow(String label, String range, String rate, Color color) {
    bool isCurrent = _projectedLevel == label;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrent ? color.withOpacity(0.2) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isCurrent ? color : Colors.black)),
                  Text(range, style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          Text(rate, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isCurrent ? color : Colors.black)),
        ],
      ),
    );
  }

  List<Color> _getLevelColors(String level) {
    switch (level) {
      case 'MASTER': return [const Color(0xFFC62828), const Color(0xFF8E0000)];
      case 'ADVISOR': return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
      default: return [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)];
    }
  }
}
