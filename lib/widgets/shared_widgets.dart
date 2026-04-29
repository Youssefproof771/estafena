import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

// ─── EGP Amount Display ────────────────────────────────────────────────────────
class EgpAmount extends StatelessWidget {
  final double amount;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const EgpAmount({
    super.key,
    required this.amount,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmt = amount.abs();
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${displayAmt.toStringAsFixed(0)} ',
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color ?? AppTheme.textPrimary,
            ),
          ),
          TextSpan(
            text: 'EGP',
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize * 0.65,
              fontWeight: FontWeight.w500,
              color: (color ?? AppTheme.textPrimary).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glowing Card ─────────────────────────────────────────────────────────────
class GlowCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color bgColor;
  final Color glowColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlowCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.bgColor,
    required this.glowColor,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: br,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: br,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Payment Method Chip ───────────────────────────────────────────────────────
class PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool readOnly;

  const PaymentMethodTile({
    super.key,
    required this.method,
    this.onEdit,
    this.onDelete,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(method.type.icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          method.type.label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          method.details,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: readOnly
            ? IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: method.details));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Copied!',
                        style: GoogleFonts.spaceGrotesk(),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: AppTheme.debtRed,
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
      ),
    );
  }
}

// ─── Empty State Widget ────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String message;

  const EmptyState({super.key, required this.emoji, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Counter ─────────────────────────────────────────────────────────
class AnimatedEgpAmount extends StatelessWidget {
  final double amount;
  final double fontSize;
  final Color color;

  const AnimatedEgpAmount({
    super.key,
    required this.amount,
    this.fontSize = 28,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) =>
          EgpAmount(amount: value, fontSize: fontSize, color: color),
    );
  }
}
