import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import 'price_tag.dart';

class ListingCardHorizontal extends StatelessWidget {
  const ListingCardHorizontal({
    super.key,
    required this.listing,
    required this.lang,
    this.onTap,
  });

  final Listing listing;
  final String lang;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final thumb = listing.photos.isNotEmpty ? listing.photos.first : '';
    return Material(
      color: NuveloColors.cardBg,
      borderRadius: BorderRadius.circular(NuveloRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 132,
                child: thumb.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: thumb,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: NuveloColors.deepCard),
                        errorWidget: (_, __, ___) =>
                            Container(color: NuveloColors.deepCard),
                      )
                    : Container(color: NuveloColors.deepCard),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
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
                      const Spacer(),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: NuveloColors.textMuted),
                            ),
                          ),
                          Text(
                            timeAgoFormatted(listing.createdAt, lang),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: NuveloColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
