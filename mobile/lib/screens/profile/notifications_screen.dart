import 'package:flutter/material.dart';

import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/notifications_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: NotificationsService().fetchForUser(uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final n = rows[i];
            return ListTile(
              leading: Icon(
                n.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: n.isRead ? NuveloColors.textMuted : NuveloColors.primaryOrange,
              ),
              title: Text(n.message),
              subtitle: Text(n.createdAt.toIso8601String()),
            );
          },
        );
      },
    );
  }
}
