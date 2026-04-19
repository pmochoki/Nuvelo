import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/user_profile.dart';

/// OAuth redirect must match AndroidManifest intent-filter + Supabase dashboard.
final Uri kOAuthRedirectUri =
    Uri(scheme: 'one.nuvelo.app', host: 'login-callback');

class AuthService {
  AuthService();

  Stream<AuthState> get onAuthStateChange =>
      supabase.auth.onAuthStateChange;

  Session? get session => supabase.auth.currentSession;
  User? get user => supabase.auth.currentUser;

  Future<void> signInWithEmailOtp(String email) async {
    await supabase.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: kOAuthRedirectUri.toString(),
    );
  }

  Future<void> signInWithPhoneOtp(String phoneE164) async {
    await supabase.auth.signInWithOtp(phone: phoneE164.trim());
  }

  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    await supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    await supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kOAuthRedirectUri.toString(),
    );
  }

  Future<void> signInWithFacebook() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: kOAuthRedirectUri.toString(),
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<UserProfile?> upsertProfileAfterLogin({
    required String displayName,
    required String role,
    String? phone,
    String? avatarUrl,
  }) async {
    final uid = user?.id;
    if (uid == null) return null;

    final row = {
      'id': uid,
      'display_name': displayName,
      'role': role,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    await supabase.from('profiles').upsert(row);
    final read =
        await supabase.from('profiles').select().eq('id', uid).maybeSingle();
    if (read == null) return null;
    return UserProfile.fromSupabase(
      Map<String, dynamic>.from(read as Map),
      authMeta: user?.userMetadata,
    );
  }
}
