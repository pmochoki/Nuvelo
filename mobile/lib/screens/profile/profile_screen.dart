import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/profile_service.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/nuvelo_app_bar.dart';
import 'feedback_screen.dart';
import 'messages_screen.dart';
import 'my_adverts_screen.dart';
import 'notifications_screen.dart';
import 'saved_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final uid = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: NuveloColors.darkNavy,
      appBar: NuveloAppBar(showBack: false, title: L.profileTitle),
      body: uid == null
          ? Center(
              child: FilledButton(
                onPressed: () => context.push('/signin?from=/profile'),
                child: Text(L.signInTitle),
              ),
            )
          : FutureBuilder(
              future: ProfileService().fetchProfile(uid),
              builder: (context, snap) {
                final p = snap.data;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AvatarWidget(
                            name: p?.displayName ?? 'User',
                            url: p?.avatarUrl,
                            size: 72,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p?.displayName ?? 'Nuvelo user',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  p?.role ?? 'buyer',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: NuveloColors.textMuted),
                                ),
                                if (p != null)
                                  Text(
                                    'Member since ${DateFormat.yMMMd().format(p.createdAt)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: NuveloColors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/profile/settings'),
                            child: const Text('Edit profile'),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tab,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Ads'),
                        Tab(text: 'Messages'),
                        Tab(text: 'Saved'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Alerts'),
                        Tab(text: 'Feedback'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tab,
                        children: const [
                          MyAdvertsScreen(),
                          MessagesScreen(),
                          SavedScreen(),
                          StatsScreen(),
                          NotificationsScreen(),
                          FeedbackScreen(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
