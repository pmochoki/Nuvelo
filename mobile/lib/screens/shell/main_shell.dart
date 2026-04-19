import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/bottom_nav_bar.dart';

/// Maps bottom navigation (5 slots including centre Sell) to [StatefulNavigationShell] branches (4 tabs).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static int shellIndexFromBottom(int bottomIndex) {
    if (bottomIndex <= 1) return bottomIndex;
    if (bottomIndex == 2) return -1;
    return bottomIndex - 1;
  }

  static int bottomIndexFromShell(int shellIndex) {
    if (shellIndex <= 1) return shellIndex;
    return shellIndex + 1;
  }

  void _onTap(BuildContext context, int bottomIndex) {
    if (bottomIndex == 2) {
      context.push('/post');
      return;
    }
    final branch = shellIndexFromBottom(bottomIndex);
    navigationShell.goBranch(branch);
  }

  @override
  Widget build(BuildContext context) {
    final currentBottom =
        bottomIndexFromShell(navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NuveloBottomNavigation(
        currentBottomIndex: currentBottom,
        messageBadgeCount: 0,
        alertBadgeCount: 0,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}
