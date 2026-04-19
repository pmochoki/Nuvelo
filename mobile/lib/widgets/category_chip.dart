import 'package:flutter/material.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../core/constants.dart';
import '../core/theme.dart';

extension NuveloCategoryTitle on NuveloCategory {
  String title(AppLocalizations L) {
    switch (labelKey) {
      case 'categoryTrending':
        return L.categoryTrending;
      case 'categoryEvents':
        return L.categoryEvents;
      case 'categoryDonations':
        return L.categoryDonations;
      case 'categoryRentals':
        return L.categoryRentals;
      case 'categoryJobs':
        return L.categoryJobs;
      case 'categoryServices':
        return L.categoryServices;
      case 'categoryGoods':
        return L.categoryGoods;
      case 'categoryVehicles':
        return L.categoryVehicles;
      case 'categoryElectronics':
        return L.categoryElectronics;
      case 'categoryFurniture':
        return L.categoryFurniture;
      case 'categoryFashion':
        return L.categoryFashion;
      case 'categoryBabiesKids':
        return L.categoryBabiesKids;
      case 'categoryOther':
        return L.categoryOther;
      default:
        return id;
    }
  }
}

class NuveloCategoryChip extends StatelessWidget {
  const NuveloCategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final NuveloCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? NuveloColors.primaryOrange.withValues(alpha: 0.25)
            : NuveloColors.deepCard,
        borderRadius: BorderRadius.circular(NuveloRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(NuveloRadii.pill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji, style: theme.textTheme.bodyMedium),
                const SizedBox(width: 6),
                Text(
                  category.title(L),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? NuveloColors.primaryOrange
                        : NuveloColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
