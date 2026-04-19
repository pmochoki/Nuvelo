import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';
import '../../services/messages_service.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/empty_state.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      return const EmptyState(title: 'Sign in to view messages');
    }

    return FutureBuilder(
      future: MessagesService().getThreads(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final threads = snap.data!;
        if (threads.isEmpty) {
          return const EmptyState(title: 'No messages yet.');
        }
        return ListView.builder(
          itemCount: threads.length,
          itemBuilder: (context, i) {
            final t = threads[i];
            final other =
                t.participantLow == uid ? t.participantHigh : t.participantLow;
            return ListTile(
              leading: AvatarWidget(name: other, url: null),
              title: Text(t.listingTitleSnapshot ?? 'Listing chat'),
              subtitle: Text(t.lastMessagePreview ?? ''),
              onTap: () =>
                  context.push('/messages/${t.id}/chat'),
            );
          },
        );
      },
    );
  }
}
