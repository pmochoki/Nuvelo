import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import 'price_tag.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.lang,
    this.dense = false,
    this.onSaveTap,
    this.saved = false,
    this.onTap,
  });

  final Listing listing;
  final String lang;
  final bool dense;
  final VoidCallback? onSaveTap;
  final VoidCallback? onTap;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final thumb = listing.photos.isNotEmpty ? listing.photos.first : '';
    final title = listing.title;

    return Material(
      color: NuveloColors.cardBg,
      borderRadius: BorderRadius.circular(NuveloRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: dense ? 16 / 10 : 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: thumb,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: NuveloColors.deepCard),
                      errorWidget: (_, __, ___) =>
                          Container(color: NuveloColors.deepCard),
                    )
                  else
                    Container(color: NuveloColors.deepCard),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: NuveloColors.darkNavy.withValues(alpha: 0.65),
                      ),
                      onPressed: onSaveTap,
                      icon: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? NuveloColors.danger : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  if (listing.sellerVerified)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: NuveloColors.success.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✓ Verified',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  PriceTag(
                    price: listing.price,
                    lang: lang,
                    priceOnRequestLabel: L.priceOnRequest,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 14, color: NuveloColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: NuveloColors.textMuted,
                              ),
                        ),
                      ),
                      Text(
                        timeAgoFormatted(listing.createdAt, lang),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: NuveloColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
