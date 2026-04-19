import 'package:realtime_client/realtime_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/message.dart';
import '../models/message_thread.dart';

class MessagesService {
  String _orderedLow(String a, String b) => a.compareTo(b) <= 0 ? a : b;
  String _orderedHigh(String a, String b) => a.compareTo(b) > 0 ? a : b;

  Future<List<MessageThread>> getThreads() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final lowRows = await supabase
        .from('message_threads')
        .select()
        .eq('participant_low', uid)
        .order('last_message_at', ascending: false);

    final highRows = await supabase
        .from('message_threads')
        .select()
        .eq('participant_high', uid)
        .order('last_message_at', ascending: false);

    final merged = <dynamic>[
      ...(lowRows as List<dynamic>? ?? []),
      ...(highRows as List<dynamic>? ?? []),
    ];

    final seen = <String>{};
    final out = <MessageThread>[];
    for (final e in merged) {
      final map = Map<String, dynamic>.from(e as Map);
      final id = map['id']?.toString();
      if (id != null && seen.add(id)) {
        out.add(MessageThread.fromSupabase(map));
      }
    }

    out.sort((a, b) {
      final ta = a.lastMessageAt ?? a.createdAt;
      final tb = b.lastMessageAt ?? b.createdAt;
      return tb.compareTo(ta);
    });
    return out;
  }

  Future<MessageThread> getOrCreateThread({
    required String listingId,
    required String sellerId,
  }) async {
    final buyerId = supabase.auth.currentUser!.id;
    final low = _orderedLow(buyerId, sellerId);
    final high = _orderedHigh(buyerId, sellerId);

    final existing = await supabase
        .from('message_threads')
        .select()
        .eq('listing_id', listingId)
        .eq('participant_low', low)
        .eq('participant_high', high)
        .maybeSingle();

    if (existing != null) {
      return MessageThread.fromSupabase(
          Map<String, dynamic>.from(existing as Map));
    }

    final insert = await supabase
        .from('message_threads')
        .insert({
          'listing_id': listingId,
          'listing_owner_id': sellerId,
          'participant_low': low,
          'participant_high': high,
        })
        .select()
        .single();

    return MessageThread.fromSupabase(Map<String, dynamic>.from(insert as Map));
  }

  Future<List<Message>> getMessages(String threadId) async {
    final rows = await supabase
        .from('messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);

    final list = rows as List<dynamic>? ?? [];
    return list
        .map((e) => Message.fromSupabase(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> sendMessage(String threadId, String content) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('messages').insert({
      'thread_id': threadId,
      'sender_id': uid,
      'body': content.trim(),
    });
  }

  RealtimeChannel subscribeToMessages(
    String threadId,
    void Function(Message) onMessage,
  ) {
    final channel = supabase.channel('messages_$threadId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'thread_id',
        value: threadId,
      ),
      callback: (payload) {
        final row = payload.newRecord;
        if (row.isEmpty) return;
        onMessage(Message.fromSupabase(row));
      },
    );

    channel.subscribe();
    return channel;
  }

  Future<void> markAsRead(String threadId) async {
    await Future<void>.delayed(Duration.zero);
  }
}
