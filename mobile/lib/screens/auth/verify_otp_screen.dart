import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../services/auth_service.dart';
import '../../widgets/nuvelo_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    this.phone,
    this.email,
    required this.nextRoute,
  });

  final String? phone;
  final String? email;
  final String nextRoute;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otp = TextEditingController();
  final _auth = AuthService();
  bool _busy = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _otp.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otp.text.trim();
    if (code.length < 6) return;
    setState(() => _busy = true);
    try {
      if (widget.phone != null) {
        await _auth.verifyPhoneOtp(
          phone: widget.phone!,
          token: code,
        );
      } else if (widget.email != null) {
        await _auth.verifyEmailOtp(
          email: widget.email!,
          token: code,
        );
      }
      if (!mounted) return;
      context.go(widget.nextRoute.startsWith('/') ? widget.nextRoute : '/home');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 0) {
        t.cancel();
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final dest =
        widget.phone ?? widget.email ?? '';

    return NuveloScreen(
      safeTop: false,
      appBar: AppBar(title: Text(L.verifyTitle)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${L.verifySmsPrompt}\n$dest',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                counterText: '',
                hintText: '______',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: Text(L.continueBtn),
            ),
            TextButton(
              onPressed: _cooldown > 0
                  ? null
                  : () {
                      _startCooldown();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(L.resendCode)),
                      );
                    },
              child: Text(
                _cooldown > 0 ? '${L.resendCode} ($_cooldown)' : L.resendCode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
