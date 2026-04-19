import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/formatters.dart';
import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../models/listing.dart';
import '../../services/listings_service.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/price_tag.dart';
import '../../widgets/status_badge.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final _svc = ListingsService();
  Listing? _listing;
  bool _loading = true;
  final _page = PageController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final l = await _svc.getListing(widget.listingId);
    await _svc.incrementViews(widget.listingId);
    setState(() {
      _listing = l;
      _loading = false;
    });
  }

  Future<void> _share() async {
    final url = 'https://nuvelo.one/listing/${widget.listingId}';
    await Share.share(url);
  }

  Future<void> _launch(Uri u) async {
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text(L.couldNotLoad)),
      );
    }

    final l = _listing!;
    final uid = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: NuveloColors.darkNavy,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: uid == null
                          ? () => context.push('/signin')
                          : () {
                              /* Chat flow: optional thread create */
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(L.sendMessage)),
                              );
                            },
                      child: Text(L.sendMessage),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: () =>
                        _launch(Uri(scheme: 'tel', path: l.sellerPhone ?? '')),
                    icon: const Icon(Icons.phone),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _launch(Uri.parse(
                      'https://wa.me/${(l.sellerPhone ?? '').replaceAll(RegExp(r'\D'), '')}',
                    )),
                    icon: const Icon(Icons.chat),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _launch(Uri(
                      scheme: 'mailto',
                      path: l.sellerEmail ?? '',
                    )),
                    icon: const Icon(Icons.email_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                L.safetyMeetPublic,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: NuveloColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => _svc.toggleSaved(l.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: _share,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: l.photos.isEmpty
                  ? Container(color: NuveloColors.deepCard)
                  : PageView.builder(
                      controller: _page,
                      itemCount: l.photos.length,
                      itemBuilder: (context, i) => CachedNetworkImage(
                        imageUrl: l.photos[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                PriceTag(
                  price: l.price,
                  lang: lang,
                  priceOnRequestLabel: L.priceOnRequest,
                ),
                const SizedBox(height: 8),
                StatusBadge(status: l.status),
                const SizedBox(height: 8),
                Text(
                  '${timeAgoFormatted(l.createdAt, lang)} · ${l.viewCount} views',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NuveloColors.textMuted,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 18, color: NuveloColors.textMuted),
                    const SizedBox(width: 6),
                    Text(l.city),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: AvatarWidget(
                      name: l.sellerName,
                      url: null,
                    ),
                    title: Text(l.sellerName),
                    subtitle: Text(
                      l.sellerVerified ? 'Verified' : 'Member',
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
