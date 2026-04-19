import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/supabase_client.dart';
import 'core/theme.dart';
import 'state/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nuvelo',
      theme: nuveloThemeLight(),
      darkTheme: nuveloThemeDark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
