// ─── Friend Model ────────────────────────────────────────────────────────────
class Friend {
  final int? id;
  final String username;
  final DateTime createdAt;

  const Friend({
    this.id,
    required this.username,
    required this.createdAt,
  });

  Friend copyWith({int? id, String? username, DateTime? createdAt}) {
    return Friend(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'created_at': createdAt.toIso8601String(),
      };

  factory Friend.fromMap(Map<String, dynamic> map) => Friend(
        id: map['id'] as int?,
        username: map['username'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

// ─── Transaction Model ────────────────────────────────────────────────────────
/// [paidByMe] = true  → I paid (they owe me)
/// [paidByMe] = false → They paid (I owe them)
class DebtTransaction {
  final int? id;
  final int friendId;
  final double amount;
  final bool paidByMe;
  final String? note;
  final DateTime createdAt;

  const DebtTransaction({
    this.id,
    required this.friendId,
    required this.amount,
    required this.paidByMe,
    this.note,
    required this.createdAt,
  });

  DebtTransaction copyWith({
    int? id,
    int? friendId,
    double? amount,
    bool? paidByMe,
    String? note,
    DateTime? createdAt,
  }) {
    return DebtTransaction(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      amount: amount ?? this.amount,
      paidByMe: paidByMe ?? this.paidByMe,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'friend_id': friendId,
        'amount': amount,
        'paid_by_me': paidByMe ? 1 : 0,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  factory DebtTransaction.fromMap(Map<String, dynamic> map) => DebtTransaction(
        id: map['id'] as int?,
        friendId: map['friend_id'] as int,
        amount: (map['amount'] as num).toDouble(),
        paidByMe: (map['paid_by_me'] as int) == 1,
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

// ─── Payment Method Model ─────────────────────────────────────────────────────
enum PaymentMethodType { instapay, vodafoneCash }

extension PaymentMethodTypeExt on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.instapay:
        return 'InstaPay';
      case PaymentMethodType.vodafoneCash:
        return 'Vodafone Cash';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethodType.instapay:
        return '💸';
      case PaymentMethodType.vodafoneCash:
        return '📱';
    }
  }

  String toDbString() => name;

  static PaymentMethodType fromDbString(String s) =>
      PaymentMethodType.values.firstWhere((e) => e.name == s,
          orElse: () => PaymentMethodType.instapay);
}

class PaymentMethod {
  final int? id;
  final int? userId; // null = belongs to the app user
  final int? friendId; // set when it belongs to a friend
  final PaymentMethodType type;
  final String details;

  const PaymentMethod({
    this.id,
    this.userId,
    this.friendId,
    required this.type,
    required this.details,
  });

  PaymentMethod copyWith({
    int? id,
    int? userId,
    int? friendId,
    PaymentMethodType? type,
    String? details,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      type: type ?? this.type,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'friend_id': friendId,
        'type': type.toDbString(),
        'details': details,
      };

  factory PaymentMethod.fromMap(Map<String, dynamic> map) => PaymentMethod(
        id: map['id'] as int?,
        userId: map['user_id'] as int?,
        friendId: map['friend_id'] as int?,
        type: PaymentMethodTypeExt.fromDbString(map['type'] as String),
        details: map['details'] as String,
      );
}

// ─── App User Model ───────────────────────────────────────────────────────────
class AppUser {
  final String username;

  const AppUser({required this.username});

  AppUser copyWith({String? username}) =>
      AppUser(username: username ?? this.username);
}

// ─── Dashboard Summary ────────────────────────────────────────────────────────
class FriendDebtSummary {
  final Friend friend;
  final double netAmount; // positive = they owe me, negative = I owe them

  const FriendDebtSummary({required this.friend, required this.netAmount});

  bool get theyOweMe => netAmount > 0;
  bool get iOweThem => netAmount < 0;
  bool get settled => netAmount == 0;
}
