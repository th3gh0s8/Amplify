import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';

class InvoicesView extends StatefulWidget {
  final String phoneNumber;
  const InvoicesView({super.key, required this.phoneNumber});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  final ApiService _apiService = ApiService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    final mobileNo = widget.phoneNumber;
    final invoices = await _apiService.getInvoices(mobileNo);
    setState(() {
      _invoices = invoices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return RefreshIndicator(
      onRefresh: _fetchInvoices,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALL INVOICES',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text('TRACK YOUR SALES AND COMMISSIONS'),
            const SizedBox(height: 24),
            if (_invoices.isEmpty)
              const Center(child: Text('NO INVOICES FOUND'))
            else
              _buildInvoicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _invoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INV-${invoice.id}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${invoice.date}',
                        style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LKR ${invoice.comAmount}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'COMMISSION',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
