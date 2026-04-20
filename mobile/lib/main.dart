import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router.dart';
import 'core/supabase_client.dart';
import 'core/theme.dart';
import 'state/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kReleaseMode) {
      await initSupabase();
    } else {
      await Supabase.initialize(
        url: const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://ahiujuljjbozmfwoqtli.supabase.co',
        ),
        anonKey: const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaXVqdWxqamJvem1md29xdGxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2MDQ5MDIsImV4cCI6MjA5MTE4MDkwMn0.q_Jz6qnkwuhU5svFDt9JShWN_KUhzc2TNKfSU5fHJOI',
        ),
      );
    }
  } catch (_) {
    // Splash screen has a fail-open fallback to route users forward.
  }

  final settings = AppSettingsController();
  await settings.load();

  final authRefresh = AuthRefreshNotifier();
  final router = createRouter(authRefresh);

  runApp(
    ChangeNotifierProvider<AppSettingsController>.value(
      value: settings,
      child: NuveloApp(router: router),
    ),
  );
}

class NuveloApp extends StatelessWidget {
  const NuveloApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();

    final baseTheme = nuveloThemeLight();
    final baseDarkTheme = nuveloThemeDark();
    const delegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nuvelo',
      theme: baseTheme,
      darkTheme: baseDarkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      routerConfig: router,
      localizationsDelegates: delegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
