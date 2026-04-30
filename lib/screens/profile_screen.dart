import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/payment_method_dialog.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _editUsername(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Username',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Your name',
            prefixIcon: Icon(
              Icons.person_rounded,
              color: AppTheme.textMuted,
              size: 18,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<AppProvider>().updateUsername(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethod(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: const PaymentMethodDialog(),
      ),
    );
  }

  void _showEditPaymentMethod(BuildContext context, method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: PaymentMethodDialog(existing: method),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: AppTheme.bg,
                floating: true,
                snap: true,
                title: const Text('Profile'),
              ),

              // Profile Header
              // Replace the old SliverToBoxAdapter with this:
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  provider: provider, // Pass the whole provider now
                  onEdit: () => _editUsername(context, provider.username),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(child: _StatsRow(provider: provider)),

              // Payment Methods
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: SectionHeader(
                    title: 'My Payment Methods',
                    trailing: TextButton.icon(
                      onPressed: () => _showAddPaymentMethod(context),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppTheme.accentGold,
                      ),
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

              if (provider.userPaymentMethods.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          const Text('💳', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 10),
                          Text(
                            'Add your payment methods so\nfriends know how to pay you back.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddPaymentMethod(context),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Method'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final method = provider.userPaymentMethods[i];
                      return PaymentMethodTile(
                        method: method,
                        onEdit: () => _showEditPaymentMethod(context, method),
                        onDelete: () =>
                            provider.deleteUserPaymentMethod(method.id!),
                      );
                    }, childCount: provider.userPaymentMethods.length),
                  ),
                ),

              // Language Settings
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: SectionHeader(title: 'Settings'),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: _LanguageSelector(
                    currentLocale: provider.locale,
                    onChanged: (locale) => provider.setLocale(locale),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final AppProvider provider;
  final VoidCallback onEdit;

  const _ProfileHeader({required this.provider, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final user = provider.currentUser;
    final isLoggedIn = user != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGold.withOpacity(0.15),
                  AppTheme.surfaceElevated,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // Avatar (Facebook Image OR Initial)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentGold, AppTheme.accentGoldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    image: isLoggedIn && provider.avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(provider.avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !isLoggedIn || provider.avatarUrl.isEmpty
                      ? Center(
                          child: Text(
                            provider.username.isNotEmpty
                                ? provider.username[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.bg,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.username,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        isLoggedIn ? 'Verified User ✨' : 'Local User 👋',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Only allow manual name edits if not logged into Facebook
                if (!isLoggedIn)
                  IconButton(
                    onPressed: onEdit,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Authentication Buttons
          if (!isLoggedIn)
            ElevatedButton(
              onPressed: () => provider.signInWithGoogle(),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white, // Google buttons are typically white
                foregroundColor: Colors.black87, // Dark text
                minimumSize: const Size(double.infinity, 50),
                elevation: 1, // Slight shadow for depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color(0xFFE0E0E0),
                  ), // Light grey border
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // A simple stylized 'G' since Flutter lacks a built-in Google icon
                  Text(
                    'G',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4285F4), // Google Blue
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: () => provider.signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.debtRed,
                side: const BorderSide(color: AppTheme.borderColor),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AppProvider provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.friends.length;
    final withDebt = provider.netBalances.values.where((v) => v != 0).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatItem(label: 'Friends', value: '$total', emoji: '👥'),
          const SizedBox(width: 12),
          _StatItem(label: 'Active debts', value: '$withDebt', emoji: '💸'),
          const SizedBox(width: 12),
          _StatItem(
            label: 'Owed to you',
            value: '${provider.totalOwedToMe.toStringAsFixed(0)}',
            emoji: '📈',
            valueColor: AppTheme.debtGreen,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.emoji,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language Selector ─────────────────────────────────────────────────────────
class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final void Function(Locale) onChanged;

  const _LanguageSelector({
    required this.currentLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('🌐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  'Language',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          _LangOption(
            flag: '🇬🇧',
            label: 'English',
            selected: currentLocale.languageCode == 'en',
            onTap: () => onChanged(const Locale('en')),
          ),
          const Divider(
            height: 1,
            color: AppTheme.borderColor,
            indent: 16,
            endIndent: 16,
          ),
          _LangOption(
            flag: '🇪🇬',
            label: 'العربية',
            selected: currentLocale.languageCode == 'ar',
            onTap: () => onChanged(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? AppTheme.accentGold : AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: AppTheme.bg,
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor, width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
