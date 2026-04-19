import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/nuvelo_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  String _role = 'buyer';
  final _auth = AuthService();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().length < 2) return;
    setState(() => _busy = true);
    try {
      await _auth.upsertProfileAfterLogin(
        displayName: _name.text.trim(),
        role: _role,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;

    return NuveloScreen(
      safeTop: false,
      appBar: AppBar(title: Text(L.registerTitle)),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(L.welcomeRegister,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: L.displayName),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: kUserRoles.map((r) {
                final label = switch (r) {
                  'buyer' => L.roleBuyer,
                  'tenant' => L.roleTenant,
                  'seller' => L.roleSeller,
                  'agent' => L.roleAgent,
                  'landlord' => L.roleLandlord,
                  _ => r,
                };
                final sel = _role == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: sel,
                    onSelected: (_) => setState(() => _role = r),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(L.createAccountBtn),
          ),
        ],
      ),
    );
  }
}
