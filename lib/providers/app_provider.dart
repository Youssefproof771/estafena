import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ─── State ─────────────────────────────────────────────────────────────────
  List<Friend> _friends = [];
  List<DebtTransaction> _transactions = [];
  List<PaymentMethod> _userPaymentMethods = [];
  Map<int, List<PaymentMethod>> _friendPaymentMethods = {};
  Map<int, double> _netBalances = {};
  String _username = 'You';
  Locale _locale = const Locale('en');
  bool _loading = true;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<Friend> get friends => _friends;
  List<DebtTransaction> get transactions => _transactions;
  List<PaymentMethod> get userPaymentMethods => _userPaymentMethods;
  Map<int, List<PaymentMethod>> get friendPaymentMethods =>
      _friendPaymentMethods;
  Map<int, double> get netBalances => _netBalances;
  Locale get locale => _locale;
  bool get loading => _loading;

  List<FriendDebtSummary> get dashboardSummaries {
    return _friends
        .map(
          (f) => FriendDebtSummary(
            friend: f,
            netAmount: _netBalances[f.id] ?? 0.0,
          ),
        )
        .where((s) => !s.settled)
        .toList()
      ..sort((a, b) => b.netAmount.abs().compareTo(a.netAmount.abs()));
  }

  double get totalOwedToMe =>
      _netBalances.values.where((v) => v > 0).fold(0.0, (a, b) => a + b);

  double get totalIOwe =>
      _netBalances.values.where((v) => v < 0).fold(0.0, (a, b) => a + b.abs());

  // ─── Auth State Getters (NEW) ──────────────────────────────────────────────
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  // Override username to use Facebook name if logged in
  String get username =>
      currentUser?.userMetadata?['full_name'] as String? ?? _username;

  // Get Facebook Avatar
  String get avatarUrl =>
      currentUser?.userMetadata?['avatar_url'] as String? ?? '';

  // ─── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _loading = true;
    notifyListeners();
    // NEW: Listen to auth state changes so the UI updates automatically after login
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
    await _loadSettings();
    await _loadFriends();
    await _loadNetBalances();
    await _loadUserPaymentMethods();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _username = await _db.getSetting('username') ?? 'You';
    final localeStr = await _db.getSetting('locale') ?? 'en';
    _locale = Locale(localeStr);
  }

  Future<void> _loadFriends() async {
    _friends = await _db.fetchFriends();
  }

  Future<void> _loadNetBalances() async {
    _netBalances = await _db.fetchNetBalances();
  }

  Future<void> _loadUserPaymentMethods() async {
    _userPaymentMethods = await _db.fetchUserPaymentMethods();
  }

  // ─── Auth Methods ──────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google, // Changed from facebook to google
      // Keep the same redirect link you set up in AndroidManifest/Info.plist
      redirectTo: 'com.example.estafena://login-callback/',
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  // ─── Username ──────────────────────────────────────────────────────────────
  Future<void> updateUsername(String name) async {
    await _db.setSetting('username', name);
    _username = name;
    notifyListeners();
  }

  // ─── Locale ────────────────────────────────────────────────────────────────
  Future<void> setLocale(Locale locale) async {
    await _db.setSetting('locale', locale.languageCode);
    _locale = locale;
    notifyListeners();
  }

  // ─── Friends ───────────────────────────────────────────────────────────────
  Future<void> addFriend(String username) async {
    if (username.trim().isEmpty) return;
    final friend = Friend(username: username.trim(), createdAt: DateTime.now());
    final id = await _db.insertFriend(friend);
    _friends.insert(0, friend.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteFriend(int id) async {
    await _db.deleteFriend(id);
    _friends.removeWhere((f) => f.id == id);
    _netBalances.remove(id);
    _friendPaymentMethods.remove(id);
    notifyListeners();
  }

  // ─── Transactions ──────────────────────────────────────────────────────────
  Future<List<DebtTransaction>> getTransactionsForFriend(int friendId) async {
    return _db.fetchTransactionsByFriend(friendId);
  }

  Future<void> addTransaction({
    required int friendId,
    required double amount,
    required bool paidByMe,
    String? note,
  }) async {
    final tx = DebtTransaction(
      friendId: friendId,
      amount: amount,
      paidByMe: paidByMe,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db.insertTransaction(tx);
    await _loadNetBalances();
    notifyListeners();
  }

  Future<void> clearDebt(int friendId) async {
    await _db.clearDebt(friendId);
    _netBalances.remove(friendId);
    notifyListeners();
  }

  // ─── Payment Methods (User) ────────────────────────────────────────────────
  Future<void> addUserPaymentMethod(
    PaymentMethodType type,
    String details,
  ) async {
    final method = PaymentMethod(type: type, details: details);
    final id = await _db.insertPaymentMethod(method);
    _userPaymentMethods.add(method.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateUserPaymentMethod(PaymentMethod method) async {
    await _db.updatePaymentMethod(method);
    final idx = _userPaymentMethods.indexWhere((m) => m.id == method.id);
    if (idx >= 0) _userPaymentMethods[idx] = method;
    notifyListeners();
  }

  Future<void> deleteUserPaymentMethod(int id) async {
    await _db.deletePaymentMethod(id);
    _userPaymentMethods.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ─── Payment Methods (Friend) ──────────────────────────────────────────────
  Future<List<PaymentMethod>> getFriendPaymentMethods(int friendId) async {
    if (_friendPaymentMethods.containsKey(friendId)) {
      return _friendPaymentMethods[friendId]!;
    }
    final methods = await _db.fetchFriendPaymentMethods(friendId);
    _friendPaymentMethods[friendId] = methods;
    return methods;
  }

  Future<void> addFriendPaymentMethod(
    int friendId,
    PaymentMethodType type,
    String details,
  ) async {
    final method = PaymentMethod(
      friendId: friendId,
      type: type,
      details: details,
    );
    final id = await _db.insertPaymentMethod(method);
    _friendPaymentMethods[friendId] ??= [];
    _friendPaymentMethods[friendId]!.add(method.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteFriendPaymentMethod(int friendId, int methodId) async {
    await _db.deletePaymentMethod(methodId);
    _friendPaymentMethods[friendId]?.removeWhere((m) => m.id == methodId);
    notifyListeners();
  }
}
