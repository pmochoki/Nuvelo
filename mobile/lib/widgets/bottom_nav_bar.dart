import 'package:flutter/material.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../core/theme.dart';

typedef NuveloNavTap = void Function(int index);

/// Five slots: Home | Browse | Sell (FAB) | Messages | Profile — matches nuvelo.one mobile nav.
class NuveloBottomNavigation extends StatelessWidget {
  const NuveloBottomNavigation({
    super.key,
    required this.currentBottomIndex,
    required this.onTap,
    this.messageBadgeCount = 0,
    this.alertBadgeCount = 0,
  });

  /// Visual index `0–4` (sell is index `2`).
  final int currentBottomIndex;
  final NuveloNavTap onTap;
  final int messageBadgeCount;
  final int alertBadgeCount;

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NuveloColors.cardBg,
        border: Border(top: BorderSide(color: NuveloColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: L.homeTitle,
                  selected: currentBottomIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.search_rounded,
                  label: L.browseTitle,
                  selected: currentBottomIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: NuveloColors.primaryOrange,
                      elevation: 4,
                      shadowColor:
                          NuveloColors.primaryOrange.withValues(alpha: 0.45),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onTap(2),
                        child: const SizedBox(
                          width: 54,
                          height: 54,
                          child: Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      L.sellTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: currentBottomIndex == 2
                                ? NuveloColors.primaryOrange
                                : NuveloColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _BadgeWrap(
                  count: messageBadgeCount,
                  child: _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: L.messagesTitle,
                    selected: currentBottomIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
              ),
              Expanded(
                child: _BadgeWrap(
                  count: alertBadgeCount,
                  child: _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: L.profileTitle,
                    selected: currentBottomIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? NuveloColors.primaryOrange : NuveloColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _BadgeWrap extends StatelessWidget {
  const _BadgeWrap({required this.child, required this.count});

  final Widget child;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 6,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: NuveloColors.primaryOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
