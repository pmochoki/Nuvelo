import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/listing.dart';
import '../../services/listings_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/nuvelo_app_bar.dart';
import '../../widgets/nuvelo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = ListingsService();
  List<Listing> _recent = [];
  List<Listing> _trending = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _svc.getListings(limit: 80, offset: 0);
      setState(() {
        _recent = all.take(20).toList();
        final sorted = [...all]
          ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
        _trending = sorted.take(24).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _lang(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    final lang = _lang(context);

    return NuveloScreen(
      safeTop: false,
      safeBottom: false,
      appBar: NuveloAppBar(
        showLogo: true,
        onSearch: () => context.push('/search'),
      ),
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Material(
                  color: NuveloColors.deepCard,
                  borderRadius: BorderRadius.circular(NuveloRadii.input),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(NuveloRadii.input),
                    onTap: () => context.push('/search'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: NuveloColors.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              L.searchPlaceholder,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: NuveloColors.textMuted),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down,
                              color: NuveloColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            L.locationAllHungary,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: kBrowseCategories.length,
                  itemBuilder: (context, i) {
                    final c = kBrowseCategories[i];
                    return NuveloCategoryChip(
                      category: c,
                      selected: false,
                      onTap: () {
                        if (c.id == kTrendingCategoryId) {
                          context.go('/browse');
                        } else {
                          context.go('/browse?category=${Uri.encodeComponent(c.id)}');
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      L.trendingAds,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    L.couldNotLoad,
                    style: const TextStyle(color: NuveloColors.danger),
                  ),
                ),
              )
            else if (_trending.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  title: L.noListingsYet,
                  actionLabel: L.postAd,
                  onAction: () => context.push('/post'),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _trending.length.clamp(0, 12),
                    itemBuilder: (context, i) {
                      final l = _trending[i];
                      return SizedBox(
                        width: 280,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ListingCard(
                            listing: l,
                            lang: lang,
                            onTap: () => context.push('/listing/${l.id}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      L.recentAds,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/browse'),
                      child: Text(L.seeAll),
                    ),
                  ],
                ),
              ),
            ),
            if (!_loading && _recent.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final l = _recent[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ListingCard(
                        listing: l,
                        lang: lang,
                        onTap: () => context.push('/listing/${l.id}'),
                      ),
                    );
                  },
                  childCount: _recent.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
