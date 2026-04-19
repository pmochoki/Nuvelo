import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/supabase_client.dart';
import '../../services/profile_service.dart';
import '../../services/storage_service.dart';
import '../../state/app_settings.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/nuvelo_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _picker = ImagePicker();

  String? _avatarUrl;
  bool _loadingProfile = true;
  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    final p = await ProfileService().fetchProfile(uid);
    if (!mounted) return;
    if (p != null) {
      final dn = p.displayName.trim();
      final parts = dn.split(RegExp(r'\s+'));
      _first.text = parts.isNotEmpty ? parts.first : '';
      _last.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _avatarUrl = p.avatarUrl;
    }
    setState(() => _loadingProfile = false);
  }

  Future<void> _pickAvatar() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (x == null) return;
    final b = await x.readAsBytes();
    setState(() => _saving = true);
    try {
      final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final url = await StorageService().uploadAvatar(
        userId: uid,
        bytes: b,
        ext: ext,
      );
      final dn = '${_first.text} ${_last.text}'.trim();
      await ProfileService().updateProfile(
        userId: uid,
        displayName: dn.isEmpty ? 'Nuvelo user' : dn,
        role: 'buyer',
        avatarUrl: url,
      );
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveChanges)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not upload photo')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfile(AppLocalizations L) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final dn = '${_first.text} ${_last.text}'.trim();
      await ProfileService().updateProfile(
        userId: uid,
        displayName: dn.isEmpty ? 'Nuvelo user' : dn,
        role: 'buyer',
        avatarUrl: _avatarUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L.saveChanges)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettingsController>();

    return NuveloScreen(
      safeTop: false,
      appBar: AppBar(title: Text(L.settingsTitle)),
      child: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      AvatarWidget(
                        name: '${_first.text} ${_last.text}'.trim().isEmpty
                            ? 'User'
                            : '${_first.text} ${_last.text}'.trim(),
                        url: _avatarUrl,
                        size: 96,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _saving ? null : _pickAvatar,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Change profile photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                    ButtonSegment(
                        value: const Locale('en'), label: Text(L.languageEn)),
                    ButtonSegment(
                        value: const Locale('hu'), label: Text(L.languageHu)),
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
                    ButtonSegment(
                        value: ThemeMode.system, label: Text(L.themeSystem)),
                    ButtonSegment(
                        value: ThemeMode.light, label: Text(L.themeLight)),
                    ButtonSegment(
                        value: ThemeMode.dark, label: Text(L.themeDark)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (set) => settings.setThemeMode(set.first),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : () => _saveProfile(L),
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
