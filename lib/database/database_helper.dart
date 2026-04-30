import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  // Get the global Supabase client
  final _supabase = Supabase.instance.client;

  // ─── Settings ──────────────────────────────────────────────────────────────
  Future<String?> getSetting(String key) async {
    final response = await _supabase
        .from('app_settings')
        .select('value')
        .eq('key', key)
        .maybeSingle();
    return response?['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await _supabase.from('app_settings').upsert({'key': key, 'value': value});
  }

  // ─── Friends CRUD ──────────────────────────────────────────────────────────
  Future<int> insertFriend(Friend friend) async {
    final response = await _supabase
        .from('friends')
        .insert(friend.toMap())
        .select('id')
        .single();
    return response['id'] as int;
  }

  Future<List<Friend>> fetchFriends() async {
    final response = await _supabase
        .from('friends')
        .select()
        .order('created_at', ascending: false);
    return response.map((e) => Friend.fromMap(e)).toList();
  }

  Future<void> deleteFriend(int id) async {
    // Supabase will automatically cascade delete transactions and payment
    // methods because of the 'on delete cascade' we set in the SQL schema!
    await _supabase.from('friends').delete().eq('id', id);
  }

  // ─── Transactions CRUD ─────────────────────────────────────────────────────
  Future<int> insertTransaction(DebtTransaction tx) async {
    final response = await _supabase
        .from('transactions')
        .insert(tx.toMap())
        .select('id')
        .single();
    return response['id'] as int;
  }

  Future<List<DebtTransaction>> fetchTransactionsByFriend(int friendId) async {
    final response = await _supabase
        .from('transactions')
        .select()
        .eq('friend_id', friendId)
        .order('created_at', ascending: false);
    return response.map((e) => DebtTransaction.fromMap(e)).toList();
  }

  Future<void> clearDebt(int friendId) async {
    await _supabase.from('transactions').delete().eq('friend_id', friendId);
  }

  Future<Map<int, double>> fetchNetBalances() async {
    final response = await _supabase
        .from('transactions')
        .select('friend_id, amount, paid_by_me');

    final Map<int, double> balances = {};
    for (final row in response) {
      final friendId = row['friend_id'] as int;
      final amount = (row['amount'] as num).toDouble();
      final paidByMe = row['paid_by_me'] as bool;

      balances[friendId] =
          (balances[friendId] ?? 0.0) + (paidByMe ? amount : -amount);
    }
    return balances;
  }

  // ─── Payment Methods CRUD ──────────────────────────────────────────────────
  Future<int> insertPaymentMethod(PaymentMethod method) async {
    final response = await _supabase
        .from('payment_methods')
        .insert(method.toMap())
        .select('id')
        .single();
    return response['id'] as int;
  }

  Future<List<PaymentMethod>> fetchUserPaymentMethods() async {
    final response = await _supabase
        .from('payment_methods')
        .select()
        .isFilter('friend_id', null);
    return response.map((e) => PaymentMethod.fromMap(e)).toList();
  }

  Future<List<PaymentMethod>> fetchFriendPaymentMethods(int friendId) async {
    final response = await _supabase
        .from('payment_methods')
        .select()
        .eq('friend_id', friendId);
    return response.map((e) => PaymentMethod.fromMap(e)).toList();
  }

  Future<void> updatePaymentMethod(PaymentMethod method) async {
    await _supabase
        .from('payment_methods')
        .update(method.toMap())
        .eq('id', method.id!);
  }

  Future<void> deletePaymentMethod(int id) async {
    await _supabase.from('payment_methods').delete().eq('id', id);
  }
}
