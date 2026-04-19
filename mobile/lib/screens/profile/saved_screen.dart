import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../services/listings_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return FutureBuilder(
      future: ListingsService().getSavedListings(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        if (rows.isEmpty) {
          return EmptyState(
            title: L.emptySaved,
            actionLabel: L.browseTitle,
            onAction: () => context.go('/browse'),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final l = rows[i];
            return ListingCard(
              listing: l,
              lang: lang,
              dense: true,
              onTap: () => context.push('/listing/${l.id}'),
            );
          },
        );
      },
    );
  }
}
