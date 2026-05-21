





import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/partner.dart';
import '../models/invoice.dart';
import '../models/payout_request.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'xpartner.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
    return await db.insert('partners', partner.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Partner?> getPartner(int mobileNo) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'partners',
      where: 'mobile_no = ?',
      whereArgs: [mobileNo],
    );
    if (maps.isNotEmpty) {
      return Partner.fromJson(maps.first);
    }
    return null;
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
    return List.generate(maps.length, (i) => Invoice.fromJson(maps[i]));
  }

  // Payout Operations
  Future<int> requestPayout(PayoutRequest request) async {
    Database db = await database;
    return await db.insert('payout_request', request.toJson());
  }
}
