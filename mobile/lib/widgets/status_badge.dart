import 'package:flutter/material.dart';

import '../core/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg;
    Color fg = Colors.white;
    String label = status;

    switch (s) {
      case 'approved':
      case 'active':
        bg = NuveloColors.success;
        label = 'ACTIVE';
        break;
      case 'pending':
        bg = NuveloColors.warning;
        label = 'PENDING REVIEW';
        break;
      case 'expired':
      case 'hidden':
        bg = NuveloColors.textMuted;
        label = s.toUpperCase();
        break;
      case 'rejected':
      case 'banned':
        bg = NuveloColors.danger;
        label = s.toUpperCase();
        break;
      default:
        bg = NuveloColors.deepCard;
        fg = NuveloColors.textPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NuveloRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
