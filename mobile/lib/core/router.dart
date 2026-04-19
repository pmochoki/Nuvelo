import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase_client.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/verify_otp_screen.dart';
import '../screens/browse/browse_screen.dart';
import '../screens/browse/listing_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/post/post_ad_screen.dart';
import '../screens/profile/chat_screen.dart';
import '../screens/profile/messages_screen.dart';
import '../screens/profile/my_adverts_screen.dart';
import '../screens/profile/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/saved_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/stats_screen.dart';
import '../screens/profile/feedback_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Notifies [GoRouter] when Supabase auth session changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    _sub = supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

GoRouter createRouter(AuthRefreshNotifier authRefresh) {
  String? redirectGuard(BuildContext context, GoRouterState state) {
    final loggedIn = supabase.auth.currentSession != null;
    final loc = state.matchedLocation;

    if (!loggedIn &&
        (loc.startsWith('/profile') ||
            loc.startsWith('/messages') ||
            loc.startsWith('/post'))) {
      final from = Uri.encodeComponent(loc);
      return '/signin?from=$from';
    }
    return null;
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: authRefresh,
    initialLocation: '/splash',
    redirect: redirectGuard,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return SignInScreen(returnTo: from);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final dest = state.uri.queryParameters['to'] ?? '/home';
          final phone = state.uri.queryParameters['phone'];
          final email = state.uri.queryParameters['email'];
          return VerifyOtpScreen(
            phone: phone,
            email: email,
            nextRoute: dest,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/listing/:lid',
        builder: (context, state) =>
            ListingDetailScreen(listingId: state.pathParameters['lid']!),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/post',
        builder: (context, state) => const PostAdScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/messages/:tid/chat',
        builder: (context, state) => ChatScreen(
          threadId: state.pathParameters['tid']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/profile/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/profile/my-ads',
        builder: (context, state) => const MyAdvertsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/profile/saved',
        builder: (context, state) => const SavedScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/profile/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/profile/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/profile/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browse',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BrowseScreen(
                    initialCategoryId:
                        state.uri.queryParameters['category'],
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MessagesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
