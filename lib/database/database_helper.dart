import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/partner.dart';
import '../models/invoice.dart';
import '../models/payout_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final _notificationStream =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _invoiceStream = StreamController<List<Invoice>>.broadcast();
  final _payoutStream =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _partnerStream = StreamController<Partner?>.broadcast();
  final _customerStream =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  final _dashboardStream = StreamController<Map<String, dynamic>?>.broadcast();

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Stream<List<Map<String, dynamic>>> get notificationStream =>
      _notificationStream.stream;
  Stream<List<Invoice>> get invoiceStream => _invoiceStream.stream;
  Stream<List<Map<String, dynamic>>> get payoutStream => _payoutStream.stream;
  Stream<Partner?> get partnerStream => _partnerStream.stream;
  Stream<List<Map<String, dynamic>>> get customerStream =>
      _customerStream.stream;
  Stream<Map<String, dynamic>?> get dashboardStream => _dashboardStream.stream;

  Map<String, dynamic>? _lastDashboardData;
  Partner? _lastPartner;
  List<Map<String, dynamic>> _lastNotifications = [];
  List<Invoice> _lastInvoices = [];
  List<Map<String, dynamic>> _lastPayouts = [];
  List<Map<String, dynamic>> _lastCustomers = [];

  // Add these getters so that outer files can read the cached variables:
  Map<String, dynamic>? get cachedDashboard => _lastDashboardData;
  Partner? get cachedPartner => _lastPartner;
  List<Map<String, dynamic>> get cachedNotifications => _lastNotifications;
  List<Invoice> get cachedInvoices => _lastInvoices;
  List<Map<String, dynamic>> get cachedPayouts => _lastPayouts;
  List<Map<String, dynamic>> get cachedCustomers => _lastCustomers;

  void updateDashboard(Map<String, dynamic>? data) {
    _lastDashboardData = data;
    _dashboardStream.add(data);
  }

  void updateInvoices(List<Invoice> invoices) {
    _lastInvoices = invoices;
    _invoiceStream.add(invoices);
  }

  void updatePayouts(List<Map<String, dynamic>> payouts) {
    _lastPayouts = payouts;
    _payoutStream.add(payouts);
  }

  void updateCustomers(List<Map<String, dynamic>> customers) {
    _lastCustomers = customers;
    _customerStream.add(customers);
  }

  Future<void> refreshNotificationStream() async {
    final list = await getNotifications();
    _notificationStream.add(list);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'xpartner.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          created_at TEXT NOT NULL,
          is_read INTEGER DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 3) {
      // Re-create partners table with correct columns
      await db.execute('DROP TABLE IF EXISTS partners');
      await db.execute('''
        CREATE TABLE partners (
          mobile_no TEXT PRIMARY KEY,
          first_name TEXT NOT NULL,
          last_name TEXT NOT NULL,
          email TEXT NOT NULL,
          c_code TEXT,
          bank_account_no TEXT,
          bank_name TEXT,
          bank_ac_branch TEXT,
          remarks TEXT,
          partner_type TEXT,
          nic_number TEXT,
          business_name TEXT,
          business_type TEXT,
          address_line1 TEXT,
          city TEXT,
          tax_id TEXT,
          website TEXT,
          status TEXT
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
        ID INTEGER PRIMARY KEY,
        br_id INTEGER NOT NULL,
        cus_code INTEGER NOT NULL,
        cus_tb INTEGER NOT NULL,
        cus_name TEXT NOT NULL,
        partner_tb INTEGER NOT NULL,
        value INTEGER NOT NULL,
        com_pres INTEGER NOT NULL,
        com_amount INTEGER NOT NULL,
        paid INTEGER NOT NULL,
        balance INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE login_activity (
        id INTEGER PRIMARY KEY,
        u_id INTEGER NOT NULL,
        act_type INTEGER NOT NULL,
        time TEXT NOT NULL,
        status INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE partners (
        mobile_no TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL,
        c_code TEXT,
        bank_account_no TEXT,
        bank_name TEXT,
        bank_ac_branch TEXT,
        remarks TEXT,
        partner_type TEXT,
        nic_number TEXT,
        business_name TEXT,
        business_type TEXT,
        address_line1 TEXT,
        city TEXT,
        tax_id TEXT,
        website TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE partner_levels (
        level_name TEXT PRIMARY KEY,
        min_coustomers INTEGER NOT NULL,
        profitPr_monthly INTEGER NOT NULL,
        profitPr_oneTime INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payout_request (
        partner_id INTEGER NOT NULL,
        request_date TEXT NOT NULL,
        request_time TEXT NOT NULL,
        amount INTEGER NOT NULL,
        status INTEGER NOT NULL,
        recipt_no INTEGER PRIMARY KEY
      )
    ''');

    await db.execute('''
      CREATE TABLE web_codes (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        u_Id INTEGER NOT NULL,
        otp_code INTEGER NOT NULL,
        time TEXT NOT NULL,
        status INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0
      )
    ''');

    // Seed data for testing
    await db.insert('partners', {
      'first_name': 'Test',
      'last_name': 'Partner',
      'mobile_no': '1234567890',
      'email': 'test@example.com',
      'bank_account_no': '987654321',
      'bank_name': 'Test Bank',
      'bank_ac_branch': 'Colombo',
    });
  }

  // Partner Operations
  Future<int> insertPartner(Partner partner) async {
    Database db = await database;
    final res = await db.insert(
      'partners',
      partner.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _lastPartner = partner;
    _partnerStream.add(partner);
    return res;
  }

  Future<Partner?> getPartner(String mobileNo) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'partners',
      where: 'mobile_no = ?',
      whereArgs: [mobileNo],
    );
    if (maps.isNotEmpty) {
      final p = Partner.fromJson(maps.first);
      _lastPartner = p;
      _partnerStream.add(p);
      return p;
    }
    _lastPartner = null;
    _partnerStream.add(null);
    return null;
  }

  // OTP / WebCode Operations
  Future<int> createOTP(int mobileNo, int code) async {
    Database db = await database;
    return await db.insert('web_codes', {
      'u_Id': mobileNo,
      'otp_code': code,
      'time': DateTime.now().toIso8601String(),
      'status': 0, // 0 = unused, 1 = used
    });
  }

  Future<bool> verifyOTP(int mobileNo, int code) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'web_codes',
      where: 'u_Id = ? AND otp_code = ? AND status = 0',
      whereArgs: [mobileNo, code],
      orderBy: 'time DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      await db.update(
        'web_codes',
        {'status': 1},
        where: 'ID = ?',
        whereArgs: [maps.first['ID']],
      );
      return true;
    }
    return false;
  }

  // Invoice Operations
  Future<List<Invoice>> getInvoicesForPartner(int mobileNo) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'invoices',
      where: 'partner_tb = ?',
      whereArgs: [mobileNo],
    );
    final invoices = List.generate(
      maps.length,
      (i) => Invoice.fromJson(maps[i]),
    );
    _invoiceStream.add(invoices);
    return invoices;
  }

  // Payout Operations
  Future<int> requestPayout(PayoutRequest request) async {
    Database db = await database;
    final res = await db.insert('payout_request', request.toJson());
    return res;
  }

  // Notification Operations (Memory-based with User-Specific Shared Preferences persistence)
  void updateNotifications(
    List<Map<String, dynamic>> notifications,
    String phone,
  ) {
    _lastNotifications = notifications;
    _notificationStream.add(notifications);

    // Save the highest ID to prevent background notification spam
    if (notifications.isNotEmpty) {
      int maxId = 0;
      for (var n in notifications) {
        final id = int.tryParse(n['id'].toString()) ?? 0;
        if (id > maxId) maxId = id;
      }
      SharedPreferences.getInstance()
          .then((prefs) {
            final lastId =
                prefs.getInt('last_seen_notification_id_$phone') ?? 0;
            if (maxId > lastId) {
              prefs.setInt('last_seen_notification_id_$phone', maxId);
            }
          })
          .catchError((e) => print('Error storing last notification ID: $e'));
    }
  }

  Future<int?> getLastNotificationId(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('last_seen_notification_id_$phone');
    } catch (e) {
      print('Error getting last notification id: $e');
      return null;
    }
  }

  void markNotificationReadInMemory(int id) {
    _lastNotifications = _lastNotifications.map((n) {
      final nid = int.tryParse(n['id'].toString()) ?? 0;
      if (nid == id) {
        final updated = Map<String, dynamic>.from(n);
        updated['is_read'] = 1;
        return updated;
      }
      return n;
    }).toList();
    _notificationStream.add(_lastNotifications);
  }

  Future<int> insertNotification(
    Map<String, dynamic> notification,
    String phone,
  ) async {
    final int id = int.tryParse(notification['id'].toString()) ?? 0;

    // Update memory list
    bool exists = false;
    for (int i = 0; i < _lastNotifications.length; i++) {
      final nid = int.tryParse(_lastNotifications[i]['id'].toString()) ?? 0;
      if (nid == id) {
        exists = true;
        _lastNotifications[i] = notification;
        break;
      }
    }
    if (!exists) {
      _lastNotifications.add(notification);
      _lastNotifications.sort((a, b) {
        final idA = int.tryParse(a['id'].toString()) ?? 0;
        final idB = int.tryParse(b['id'].toString()) ?? 0;
        return idB.compareTo(idA);
      });
    }
    _notificationStream.add(_lastNotifications);

    // Save persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getInt('last_seen_notification_id_$phone') ?? 0;
      if (id > lastId) {
        await prefs.setInt('last_seen_notification_id_$phone', id);
      }
    } catch (e) {
      print('Error saving last notification id: $e');
    }

    return 1;
  }

  // Keep these async signatures to prevent code compilation errors elsewhere
  Future<List<Map<String, dynamic>>> getNotifications() async {
    return _lastNotifications;
  }

  Future<int> markNotificationsRead() async {
    _lastNotifications = _lastNotifications.map((n) {
      final updated = Map<String, dynamic>.from(n);
      updated['is_read'] = 1;
      return updated;
    }).toList();
    _notificationStream.add(_lastNotifications);
    return 1;
  }

  Future<int> markSingleNotificationRead(int id) async {
    markNotificationReadInMemory(id);
    return 1;
  }

  // Customer Operations
  Future<void> syncCustomers(List<Map<String, dynamic>> customers) async {
    Database db = await database;
    for (var c in customers) {
      await db.insert(
        'new_clients',
        c,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    _customerStream.add(customers);
  }
}
