import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class NuveloAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NuveloAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBack = false,
    this.notificationCount = 0,
    this.onSearch,
  });

  final String? title;
  final bool showLogo;
  final bool showBack;
  final int notificationCount;
  final VoidCallback? onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            )
          : showLogo
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SvgPicture.asset(
                    'assets/images/nuvelo-logo.svg',
                    height: 28,
                  ),
                )
              : null,
      title: title != null
          ? Text(title!)
          : (!showLogo && !showBack
              ? SvgPicture.asset(
                  'assets/images/nuvelo-logo.svg',
                  height: 26,
                )
              : null),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: onSearch ?? () => context.push('/search'),
        ),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => context.push('/profile/notifications'),
            ),
            if (notificationCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: NuveloColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
