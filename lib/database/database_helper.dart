import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'estafena.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        friend_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        paid_by_me INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (friend_id) REFERENCES friends(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        friend_id INTEGER,
        type TEXT NOT NULL,
        details TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed default username
    await db.insert('app_settings', {'key': 'username', 'value': 'You'});
    await db.insert('app_settings', {'key': 'locale', 'value': 'en'});
  }

  // ─── Settings ──────────────────────────────────────────────────────────────
  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Friends CRUD ──────────────────────────────────────────────────────────
  Future<int> insertFriend(Friend friend) async {
    final db = await database;
    return db.insert('friends', friend.toMap());
  }

  Future<List<Friend>> fetchFriends() async {
    final db = await database;
    final rows = await db.query('friends', orderBy: 'created_at DESC');
    return rows.map(Friend.fromMap).toList();
  }

  Future<void> deleteFriend(int id) async {
    final db = await database;
    await db.delete('friends', where: 'id = ?', whereArgs: [id]);
    await db.delete('transactions', where: 'friend_id = ?', whereArgs: [id]);
    await db.delete('payment_methods', where: 'friend_id = ?', whereArgs: [id]);
  }

  // ─── Transactions CRUD ─────────────────────────────────────────────────────
  Future<int> insertTransaction(DebtTransaction tx) async {
    final db = await database;
    return db.insert('transactions', tx.toMap());
  }

  Future<List<DebtTransaction>> fetchTransactionsByFriend(int friendId) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'friend_id = ?',
      whereArgs: [friendId],
      orderBy: 'created_at DESC',
    );
    return rows.map(DebtTransaction.fromMap).toList();
  }

  Future<void> clearDebt(int friendId) async {
    final db = await database;
    await db.delete('transactions', where: 'friend_id = ?', whereArgs: [friendId]);
  }

  Future<Map<int, double>> fetchNetBalances() async {
    final db = await database;
    final rows = await db.query('transactions');
    final Map<int, double> balances = {};
    for (final row in rows) {
      final friendId = row['friend_id'] as int;
      final amount = (row['amount'] as num).toDouble();
      final paidByMe = (row['paid_by_me'] as int) == 1;
      balances[friendId] = (balances[friendId] ?? 0.0) + (paidByMe ? amount : -amount);
    }
    return balances;
  }

  // ─── Payment Methods CRUD ──────────────────────────────────────────────────
  Future<int> insertPaymentMethod(PaymentMethod method) async {
    final db = await database;
    return db.insert('payment_methods', method.toMap());
  }

  Future<List<PaymentMethod>> fetchUserPaymentMethods() async {
    final db = await database;
    final rows = await db.query(
      'payment_methods',
      where: 'friend_id IS NULL',
    );
    return rows.map(PaymentMethod.fromMap).toList();
  }

  Future<List<PaymentMethod>> fetchFriendPaymentMethods(int friendId) async {
    final db = await database;
    final rows = await db.query(
      'payment_methods',
      where: 'friend_id = ?',
      whereArgs: [friendId],
    );
    return rows.map(PaymentMethod.fromMap).toList();
  }

  Future<void> updatePaymentMethod(PaymentMethod method) async {
    final db = await database;
    await db.update(
      'payment_methods',
      method.toMap(),
      where: 'id = ?',
      whereArgs: [method.id],
    );
  }

  Future<void> deletePaymentMethod(int id) async {
    final db = await database;
    await db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }
}
