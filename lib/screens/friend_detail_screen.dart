import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/payment_method_dialog.dart';
import '../widgets/shared_widgets.dart';

class FriendDetailScreen extends StatefulWidget {
  final Friend friend;

  const FriendDetailScreen({super.key, required this.friend});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  List<DebtTransaction> _transactions = [];
  List<PaymentMethod> _paymentMethods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<AppProvider>();
    final txs =
        await provider.getTransactionsForFriend(widget.friend.id!);
    final methods =
        await provider.getFriendPaymentMethods(widget.friend.id!);
    if (mounted) {
      setState(() {
        _transactions = txs;
        _paymentMethods = methods;
        _loading = false;
      });
    }
  }

  void _addTransaction() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: AddTransactionSheet(friend: widget.friend),
      ),
    );
    _loadData();
  }

  void _addPaymentMethod() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: PaymentMethodDialog(friendId: widget.friend.id),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final net = provider.netBalances[widget.friend.id] ?? 0.0;
    final isPositive = net >= 0;
    final accentColor =
        isPositive ? AppTheme.debtGreen : AppTheme.debtRed;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.friend.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppTheme.accentGold),
            onPressed: _addTransaction,
            tooltip: 'Add Transaction',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Net balance banner
                SliverToBoxAdapter(
                  child: _NetBanner(
                    net: net,
                    accentColor: accentColor,
                    friendName: widget.friend.username,
                    isPositive: isPositive,
                  ),
                ),

                // Payment Methods Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: SectionHeader(
                      title: "${widget.friend.username}'s Payment Methods",
                      trailing: TextButton.icon(
                        onPressed: _addPaymentMethod,
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: AppTheme.accentGold),
                        label: Text(
                          'Add',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (_paymentMethods.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => PaymentMethodTile(
                          method: _paymentMethods[i],
                          readOnly: false,
                          onDelete: () async {
                            await context
                                .read<AppProvider>()
                                .deleteFriendPaymentMethod(
                                    widget.friend.id!,
                                    _paymentMethods[i].id!);
                            _loadData();
                          },
                        ),
                        childCount: _paymentMethods.length,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          'No payment methods added yet. Tap + Add to add one.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Transactions Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: SectionHeader(title: 'Transaction History'),
                  ),
                ),

                if (_transactions.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Center(
                          child: Text(
                            'No transactions yet.\nTap + to add the first one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _TransactionRow(tx: _transactions[i]),
                        childCount: _transactions.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ─── Net Banner ───────────────────────────────────────────────────────────────
class _NetBanner extends StatelessWidget {
  final double net;
  final Color accentColor;
  final String friendName;
  final bool isPositive;

  const _NetBanner({
    required this.net,
    required this.accentColor,
    required this.friendName,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPositive ? AppTheme.debtGreenBg : AppTheme.debtRedBg;
    final borderColor =
        isPositive ? AppTheme.debtGreenBorder : AppTheme.debtRedBorder;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPositive
                      ? '$friendName owes you'
                      : 'You owe $friendName',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: accentColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                EgpAmount(
                  amount: net,
                  fontSize: 28,
                  color: accentColor,
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                isPositive ? '📈' : '📉',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Row ─────────────────────────────────────────────────────────
class _TransactionRow extends StatelessWidget {
  final DebtTransaction tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIPaid = tx.paidByMe;
    final color = isIPaid ? AppTheme.debtGreen : AppTheme.debtRed;
    final sign = isIPaid ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                isIPaid
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIPaid ? 'I paid' : 'They paid',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (tx.note != null && tx.note!.isNotEmpty)
                  Text(
                    tx.note!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                Text(
                  _formatDate(tx.createdAt),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${tx.amount.toStringAsFixed(0)} EGP',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
