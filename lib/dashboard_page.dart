import 'package:flutter/material.dart';
import 'views/dashboard_view.dart';
import 'views/invoices_view.dart';
import 'views/payouts_view.dart';
import 'views/profile_view.dart';
import 'views/add_customer_page.dart';

class DashboardPage extends StatefulWidget {
  final String phoneNumber;
  const DashboardPage({super.key, required this.phoneNumber});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  Key _dashboardKey = UniqueKey();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            DashboardView(key: _dashboardKey, phoneNumber: widget.phoneNumber),
            InvoicesView(phoneNumber: widget.phoneNumber),
            PayoutsView(phoneNumber: widget.phoneNumber),
            ProfileView(phoneNumber: widget.phoneNumber),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerPage(phoneNumber: widget.phoneNumber)),
          );
          
          if (result == true) {
            // Force recreation of DashboardView by changing its key
            setState(() {
              _selectedIndex = 0;
              _dashboardKey = UniqueKey();
            });
          }
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 70,
      color: Colors.white,
      notchMargin: 8,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.grid_view_rounded, 'HOME'),
          _buildNavItem(1, Icons.receipt_long_rounded, 'INVOICES'),
          const SizedBox(width: 48), // Space for FAB
          _buildNavItem(2, Icons.account_balance_wallet_rounded, 'PAYOUTS'),
          _buildNavItem(3, Icons.person_rounded, 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
              color: isSelected ? Colors.black : Colors.black.withOpacity(0.3),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
