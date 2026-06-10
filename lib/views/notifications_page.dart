import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';
import '../widgets/system_overlay_wrapper.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class NotificationsPage extends StatefulWidget {
  final String mobileNo;
  const NotificationsPage({super.key, required this.mobileNo});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    // Listen to real-time memory stream updates:
    _notificationSubscription = _dbHelper.notificationStream.listen((
      notifications,
    ) {
      if (mounted) {
        _notifications = notifications;
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    // 1. Load from cache first
    final cached = await _dbHelper.getNotifications();
    setState(() {
      _notifications = cached;
      if (cached.isNotEmpty) _isLoading = false; // Show cached data immediately
    });

    // 2. Sync from API
    try {
      final apiData = await _apiService.getNotifications(widget.mobileNo);
      _dbHelper.updateNotifications(apiData, widget.mobileNo);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Sync Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Extract notifications directly from state
    final data = _notifications;
    final unread = data.where((n) => n['is_read'] == 0).toList();
    final viewed = data.where((n) => n['is_read'] == 1).toList();

    return SystemOverlayWrapper(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            title: const Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
                color: Colors.black,
              ),
            ),
            bottom: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'NEW'),
                Tab(text: 'VIEWED'),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh, size: 20, color: Colors.black),
              ),
            ],
          ),
          // 2. Render lists directly based on _isLoading
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                )
              : TabBarView(
                  children: [
                    _buildList(unread, false),
                    _buildList(viewed, true),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, bool isViewed) {
    if (items.isEmpty) return const Center(child: Text("No notifications"));
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = items[index];
        final card = _buildNotificationCard(item, isViewed);

        if (isViewed) {
          return card; // Swipe-to-read is only for unread (NEW) notifications
        }

        // Wrap with Dismissible for swipe gestures
        return Dismissible(
          key: ValueKey(item['id'].toString()),
          direction: DismissDirection.endToStart, // Swipe right-to-left
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          onDismissed: (direction) async {
            final idInt = int.tryParse(item['id'].toString()) ?? 0;
            // Mark read locally instantly in memory
            _dbHelper.markNotificationReadInMemory(idInt);
            // Sync status with server backend
            await _apiService.markNotificationSingleRead(
              widget.mobileNo,
              idInt,
            );
          },
          child: card,
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, bool isViewed) {
    final formattedDate = DateFormat(
      'MMM d, hh:mm a',
    ).format(DateTime.parse(item['created_at']));
    return Opacity(
      opacity: isViewed ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (!isViewed)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            item['title'].toString().toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['message'].toString(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
