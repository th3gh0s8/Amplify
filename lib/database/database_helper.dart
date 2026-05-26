





import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/partner.dart';
import '../models/invoice.dart';
import '../models/payout_request.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final _notificationStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _invoiceStream = StreamController<List<Invoice>>.broadcast();
  final _payoutStream = StreamController<List<PayoutRequest>>.broadcast();
  final _partnerStream = StreamController<Partner?>.broadcast();
  final _customerStream = StreamController<List<Map<String, dynamic>>>.broadcast();

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Stream<List<Map<String, dynamic>>> get notificationStream => _notificationStream.stream;
  Stream<List<Invoice>> get invoiceStream => _invoiceStream.stream;
  Stream<List<PayoutRequest>> get payoutStream => _payoutStream.stream;
  Stream<Partner?> get partnerStream => _partnerStream.stream;
  Stream<List<Map<String, dynamic>>> get customerStream => _customerStream.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'xpartner.db');
    return await openDatabase(
      path,
      version: 2,
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
        mobile_no INTEGER PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL,
        bank_account_no INTEGER NOT NULL,
        bank_name TEXT NOT NULL,
        bank_account_type TEXT NOT NULL
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
      'mobile_no': 1234567890,
      'email': 'test@example.com',
      'bank_account_no': 987654321,
      'bank_name': 'Test Bank',
      'bank_account_type': 'Savings'
    });
  }

  // Partner Operations
  Future<int> insertPartner(Partner partner) async {
    Database db = await database;
    final res = await db.insert('partners', partner.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    _partnerStream.add(partner);
    return res;
  }

  Future<Partner?> getPartner(int mobileNo) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'partners',
      where: 'mobile_no = ?',
      whereArgs: [mobileNo],
    );
    if (maps.isNotEmpty) {
      final p = Partner.fromJson(maps.first);
      _partnerStream.add(p);
      return p;
    }
    _partnerStream.add(null);
    return null;
  }

  // Customer Operations
  Future<void> syncCustomers(List<Map<String, dynamic>> customers) async {
    Database db = await database;
    for (var c in customers) {
      await db.insert('new_clients', c, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    _customerStream.add(customers);
  }

  // OTP / WebCode Operations
  Future<int> createOTP(int mobileNo, int code) async {
    Database db = await database;
    return await db.insert('web_codes', {
      'u_Id': mobileNo,
      'otp_code': code,
      'time': DateTime.now().toIso8601String(),
      'status': 0 // 0 = unused, 1 = used
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
    final invoices = List.generate(maps.length, (i) => Invoice.fromJson(maps[i]));
    _invoiceStream.add(invoices);
    return invoices;
  }

  // Payout Operations
  Future<int> requestPayout(PayoutRequest request) async {
    Database db = await database;
    final res = await db.insert('payout_request', request.toJson());
    // In real app, fetch updated list here and add to stream
    return res;
  }

  // Notification Operations
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    Database db = await database;
    final res = await db.insert('notifications', {
      'id': int.tryParse(notification['id'].toString()) ?? 0,
      'title': notification['title'],
      'message': notification['message'],
      'created_at': notification['created_at'],
      'is_read': notification['is_read'] ?? 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    
    _notificationStream.add(await getNotifications());
    return res;
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    Database db = await database;
    return await db.query('notifications', orderBy: 'id DESC');
  }

  Future<int> markNotificationsRead() async {
    Database db = await database;
    final res = await db.update('notifications', {'is_read': 1});
    _notificationStream.add(await getNotifications());
    return res;
  }

  Future<int?> getLastNotificationId() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'notifications',
      columns: ['id'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    }
    return null;
  }
}
