import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/nuvelo_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.returnTo});

  final String? returnTo;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _auth = AuthService();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _oauth(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete sign-in in your browser when prompted — you will return to Nuvelo automatically.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueEmailPhone() async {
    final email = _email.text.trim();
    final rawPhone = _phone.text.trim().replaceAll(RegExp(r'\s'), '');
    setState(() => _busy = true);
    try {
      if (email.isNotEmpty) {
        await _auth.signInWithEmailOtp(email);
        if (!mounted) return;
        context.push(
          '/verify?email=${Uri.encodeComponent(email)}&to=${Uri.encodeComponent(widget.returnTo ?? '/home')}',
        );
      } else if (rawPhone.isNotEmpty) {
        final e164 =
            rawPhone.startsWith('+') ? rawPhone : '+36${rawPhone.replaceFirst(RegExp(r'^0+'), '')}';
        await _auth.signInWithPhoneOtp(e164);
        if (!mounted) return;
        context.push(
          '/verify?phone=${Uri.encodeComponent(e164)}&to=${Uri.encodeComponent(widget.returnTo ?? '/home')}',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter email or phone')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send code')),
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
      appBar: AppBar(title: Text(L.signInTitle)),
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                'assets/images/nuvelo-logo.svg',
                height: 40,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _busy ? null : () => _oauth(_auth.signInWithGoogle),
                child: Text(L.continueWithGoogle),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                ),
                onPressed:
                    _busy ? null : () => _oauth(_auth.signInWithFacebook),
                child: Text(L.continueWithFacebook),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: NuveloColors.borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(L.orDivider,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider(color: NuveloColors.borderColor)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: L.email),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: ''),
                      initialValue: '+36',
                      items: const [
                        DropdownMenuItem(value: '+36', child: Text('+36')),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d\s+]')),
                      ],
                      decoration: InputDecoration(labelText: L.phone),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _continueEmailPhone,
                child: Text(L.continueBtn),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(L.dontHaveAccount),
              ),
              const SizedBox(height: 24),
              Text(
                L.termsFooter,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: NuveloColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
    );
  }
}
