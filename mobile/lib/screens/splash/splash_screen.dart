import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/profile_service.dart';
import '../../widgets/nuvelo_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goNext);
  }

  Future<void> _goNext() async {
    try {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(kPrefsOnboardingDone) ??
          prefs.getBool('nuvelo_onboarding_done') ??
          false;
      final loggedIn = supabase.auth.currentSession != null;

      if (!mounted) return;

      if (loggedIn) {
        final uid = supabase.auth.currentUser?.id;
        if (uid != null) {
          final profile = await ProfileService().fetchProfile(uid);
          if (!mounted) return;
          if (profile == null) {
            context.go('/register');
            return;
          }
        }
        if (!mounted) return;
        context.go('/home');
        return;
      }
      if (!done) {
        context.go('/onboarding');
        return;
      }
      context.go('/home');
    } catch (_) {
      // Never block users on splash if auth/network/init has transient issues.
      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    return NuveloScreen(
      dismissKeyboard: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/nuvelo-logo.svg',
              height: 56,
            ),
            const SizedBox(height: 24),
            Text(
              L.taglineNiceVibesOnly,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NuveloColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
