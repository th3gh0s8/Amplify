import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PayoutsView extends StatefulWidget {
  final String phoneNumber;
  const PayoutsView({super.key, required this.phoneNumber});

  @override
  State<PayoutsView> createState() => _PayoutsViewState();
}

class _PayoutsViewState extends State<PayoutsView> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _payouts = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _fetchPayoutData();
  }

  Future<void> _fetchPayoutData() async {
    final mobileNo = widget.phoneNumber;
    final payouts = await _apiService.getPayouts(mobileNo);
    final dashboard = await _apiService.getDashboardData(mobileNo);
    setState(() {
      _payouts = payouts;
      _dashboardData = dashboard;
      _isLoading = false;
    });
  }

  Future<void> _handlePayoutRequest() async {
    final availableBalance = double.tryParse(_dashboardData?['available_balance']?.toString() ?? '0') ?? 0;
    
    if (availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('INSUFFICIENT BALANCE')));
      return;
    }

    // Show dialog to enter amount
    final TextEditingController amountController = TextEditingController(text: availableBalance.toStringAsFixed(2));
    
    final requestedAmount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('REQUEST PAYOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AVAILABLE: LKR ${availableBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                labelText: 'AMOUNT (LKR)',
                fillColor: Colors.black.withOpacity(0.03),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () {
              final val = double.tryParse(amountController.text);
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ENTER VALID AMOUNT')));
                return;
              }
              if (val > availableBalance) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('EXCEEDS AVAILABLE BALANCE')));
                return;
              }
              Navigator.pop(context, val);
            },
            child: const Text('REQUEST'),
          ),
        ],
      ),
    );

    if (requestedAmount == null) return;

    setState(() => _isRequesting = true);
    final mobileNo = widget.phoneNumber;
    
    final result = await _apiService.requestPayout(mobileNo, requestedAmount);
      
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PAYOUT REQUESTED SUCCESSFULLY')));
        _fetchPayoutData();
      } else if (result['code'] == 'MISSING_BANK') {
        _showBankMissingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
    setState(() => _isRequesting = false);
  }

  void _showBankMissingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('BANK DETAILS MISSING'),
        content: const Text('Please update your bank details in the Profile tab before requesting a payout.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return RefreshIndicator(
      onRefresh: _fetchPayoutData,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PAYOUTS',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
            const SizedBox(height: 24),
            _buildBalanceCard(),
            const SizedBox(height: 40),
            const Text(
              'PAYOUT HISTORY', 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38)
            ),
            const SizedBox(height: 16),
            _buildPayoutList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF424242), Color(0xFF212121)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'AVAILABLE BALANCE', 
            style: TextStyle(
              color: Colors.white.withOpacity(0.5), 
              fontSize: 11, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 1.5
            )
          ),
          const SizedBox(height: 12),
          Text(
            'LKR ${_dashboardData?['available_balance'] ?? '0.00'}',
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 36, 
              fontWeight: FontWeight.w900,
              letterSpacing: -1
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: _isRequesting ? null : _handlePayoutRequest,
              child: _isRequesting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                : const Text(
                    'REQUEST PAYOUT', 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutList() {
    if (_payouts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('NO HISTORY YET')));
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _payouts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payout = _payouts[index];
        final status = payout['status'].toString().toLowerCase();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYOUT #${payout['recipt_no']}', 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${payout['request_date']}', 
                        style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w700)
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: _getStatusColor(status)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'LKR ${payout['amount']}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'completed': return Colors.green;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }
}
