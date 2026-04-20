import '../core/supabase_client.dart';
import '../models/user_profile.dart';

class ProfileService {
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final row =
          await supabase.from('profiles').select().eq('id', userId).maybeSingle();
      if (row == null) return null;
      final u = supabase.auth.currentUser;
      return UserProfile.fromSupabase(
        Map<String, dynamic>.from(row as Map),
        authMeta: u?.userMetadata,
      );
    } catch (_) {
      // Fail-safe for first-run/dev environments where `profiles` is not yet migrated.
      // Splash flow treats null as "profile missing" and routes to /register.
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String displayName,
    required String role,
    String? phone,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'display_name': displayName,
      'role': role,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    await supabase.from('profiles').update(payload).eq('id', userId);
  }
}
