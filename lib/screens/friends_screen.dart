import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'friend_detail_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  void _showAddFriendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: const _AddFriendSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showAddFriendSheet(context),
              icon: const Icon(Icons.person_add_rounded,
                  size: 18, color: AppTheme.accentGold),
              label: Text(
                'Add',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final friends = provider.friends;

          if (friends.isEmpty) {
            return const EmptyState(
              emoji: '👥',
              message: 'No friends yet.\nAdd someone to get started!',
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: friends.length,
            itemBuilder: (ctx, i) =>
                _FriendListItem(friend: friends[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendSheet(context),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}

// ─── Friend List Item ─────────────────────────────────────────────────────────
class _FriendListItem extends StatelessWidget {
  final Friend friend;

  const _FriendListItem({required this.friend});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final net = provider.netBalances[friend.id] ?? 0.0;
    final hasDebt = net != 0;
    final isPositive = net > 0;
    final debtColor = isPositive ? AppTheme.debtGreen : AppTheme.debtRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(friend.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => _confirmDelete(context),
              backgroundColor: AppTheme.debtRed,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendDetailScreen(friend: friend),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasDebt
                          ? [
                              debtColor.withOpacity(0.3),
                              debtColor.withOpacity(0.1),
                            ]
                          : [
                              AppTheme.accentGold.withOpacity(0.2),
                              AppTheme.accentGold.withOpacity(0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      friend.username[0].toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: hasDebt ? debtColor : AppTheme.accentGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name + status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.username,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasDebt
                            ? (isPositive ? 'Owes you' : 'You owe')
                            : 'All settled ✓',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: hasDebt
                              ? debtColor.withOpacity(0.8)
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Net amount
                if (hasDebt)
                  EgpAmount(
                    amount: net,
                    fontSize: 15,
                    color: debtColor,
                  )
                else
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppTheme.textMuted, size: 20),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Friend',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Remove ${friend.username} and all their transactions?',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteFriend(friend.id!);
              Navigator.pop(ctx);
            },
            child: Text(
              'Remove',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.debtRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Friend Sheet ─────────────────────────────────────────────────────────
class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet();

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AppProvider>().addFriend(_ctrl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('👤',
                style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'Add a Friend',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start tracking debts with them',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _ctrl,
              autofocus: true,
              style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                labelText: "Friend's username",
                prefixIcon: Icon(Icons.alternate_email_rounded,
                    color: AppTheme.textMuted, size: 18),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _add(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _add,
                child: const Text('Add Friend'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
