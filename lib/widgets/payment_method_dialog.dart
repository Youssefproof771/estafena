import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class PaymentMethodDialog extends StatefulWidget {
  final PaymentMethod? existing;
  final int? friendId; // null = user's own method

  const PaymentMethodDialog({super.key, this.existing, this.friendId});

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  late PaymentMethodType _selectedType;
  late TextEditingController _detailsCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existing?.type ?? PaymentMethodType.instapay;
    _detailsCtrl = TextEditingController(text: widget.existing?.details ?? '');
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    if (widget.existing != null) {
      await provider.updateUserPaymentMethod(
        widget.existing!.copyWith(
          type: _selectedType,
          details: _detailsCtrl.text.trim(),
        ),
      );
    } else if (widget.friendId != null) {
      await provider.addFriendPaymentMethod(
          widget.friendId!, _selectedType, _detailsCtrl.text.trim());
    } else {
      await provider.addUserPaymentMethod(_selectedType, _detailsCtrl.text.trim());
    }
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
            // Handle
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
            Text(
              widget.existing != null ? 'Edit Payment Method' : 'Add Payment Method',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'METHOD TYPE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: PaymentMethodType.values.map((type) {
                final selected = _selectedType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: type == PaymentMethodType.instapay
                          ? const EdgeInsets.only(right: 8)
                          : const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accentGold.withOpacity(0.15)
                            : AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppTheme.accentGold
                              : AppTheme.borderColor,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(type.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 6),
                          Text(
                            type.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppTheme.accentGold
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _detailsCtrl,
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: _selectedType == PaymentMethodType.instapay
                    ? 'InstaPay Handle (@username)'
                    : 'Vodafone Cash Number',
                prefixIcon: Icon(
                  _selectedType == PaymentMethodType.instapay
                      ? Icons.alternate_email_rounded
                      : Icons.phone_rounded,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              keyboardType: _selectedType == PaymentMethodType.vodafoneCash
                  ? TextInputType.phone
                  : TextInputType.text,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(widget.existing != null ? 'Save Changes' : 'Add Method'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
