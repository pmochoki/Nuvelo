import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Loads [assets/env] when present, then falls back to `--dart-define` values.
Future<void> initSupabase() async {
  await dotenv.load(fileName: 'assets/env', isOptional: true);

  final fromFileUrl = dotenv.env['SUPABASE_URL']?.trim();
  final fromFileKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();

  final url = (fromFileUrl != null && fromFileUrl.isNotEmpty)
      ? fromFileUrl
      : const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  final anonKey = (fromFileKey != null && fromFileKey.isNotEmpty)
      ? fromFileKey
      : const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Set SUPABASE_URL and SUPABASE_ANON_KEY '
      'in assets/env (see assets/env in repo), or pass '
      '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

SupabaseClient get supabase => Supabase.instance.client;
