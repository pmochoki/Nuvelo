import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';
import '../../models/listing.dart';
import '../../services/listings_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

class MyAdvertsScreen extends StatelessWidget {
  const MyAdvertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return const SizedBox.shrink();

    return FutureBuilder<List<Listing>>(
      future: ListingsService().getListings(userId: uid, limit: 100),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        if (rows.isEmpty) {
          return EmptyState(
            title: 'No ads yet',
            actionLabel: 'Post ad',
            onAction: () => context.push('/post'),
          );
        }
        final lang = Localizations.localeOf(context).languageCode;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final l = rows[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListingCard(
                listing: l,
                lang: lang,
                onTap: () => context.push('/listing/${l.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
