import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/profile_service.dart';
import '../../state/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettingsController>();

    return Scaffold(
      backgroundColor: NuveloColors.darkNavy,
      appBar: AppBar(title: Text(L.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _first,
            decoration: const InputDecoration(labelText: 'First name'),
          ),
          TextField(
            controller: _last,
            decoration: const InputDecoration(labelText: 'Last name'),
          ),
          const SizedBox(height: 24),
          Text(L.languageEn, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<Locale>(
            segments: [
              ButtonSegment(value: const Locale('en'), label: Text(L.languageEn)),
              ButtonSegment(value: const Locale('hu'), label: Text(L.languageHu)),
            ],
            selected: {settings.locale},
            onSelectionChanged: (set) {
              final loc = set.first;
              settings.setLocale(loc);
            },
          ),
          const SizedBox(height: 24),
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(L.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(L.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(L.themeDark)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (set) => settings.setThemeMode(set.first),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () async {
              final uid = supabase.auth.currentUser?.id;
              if (uid == null) return;
              final dn = '${_first.text} ${_last.text}'.trim();
              await ProfileService().updateProfile(
                userId: uid,
                displayName: dn.isEmpty ? 'Nuvelo user' : dn,
                role: 'buyer',
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L.saveChanges)),
              );
            },
            child: Text(L.saveChanges),
          ),
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (!context.mounted) return;
              context.go('/home');
            },
            child: Text(L.signOut),
          ),
        ],
      ),
    );
  }
}
