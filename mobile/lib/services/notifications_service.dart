import '../core/supabase_client.dart';
import '../models/notification.dart';

class NotificationsService {
  Future<List<AppNotification>> fetchForUser(String userId) async {
    final rows = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    final list = rows as List<dynamic>;
    return list
        .map((e) => AppNotification.fromSupabase(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> markAllRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true}).eq('user_id', userId);
  }
}
