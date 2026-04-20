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
import '../../widgets/listing_card_horizontal.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/nuvelo_app_bar.dart';
import '../../widgets/nuvelo_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _svc = ListingsService();
  final _scroll = ScrollController();
  final _search = TextEditingController();

  List<Listing> _items = [];
  bool _loading = true;
  bool _fetching = false;
  bool _grid = true;
  String? _category;
  String _sort = 'created_at';
  String _city = 'All Hungary';
  int _offset = 0;
  final int _page = 20;
  bool _end = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategoryId;
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_fetching) return;
    if (_loading && !reset) return;
    if (reset) {
      _offset = 0;
      _end = false;
      _items = [];
    }
    if (_end && !reset) return;

    setState(() {
      _loading = true;
      _fetching = true;
    });
    try {
      final rows = await _svc.getListings(
        category: _category == kTrendingCategoryId ? null : _category,
        city: _city == 'All Hungary' ? null : _city,
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
        sortBy: _sort,
        limit: _page,
        offset: _offset,
      );
      setState(() {
        _items.addAll(rows);
        _offset += rows.length;
        if (rows.length < _page) _end = true;
        _loading = false;
        _fetching = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _fetching = false;
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
        title: L.browseTitle,
        showBack: false,
        onSearch: () => context.push('/search'),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: L.searchPlaceholder,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _load(reset: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: NuveloColors.cardBg,
                    builder: (ctx) => _FilterSheet(
                      city: _city,
                      onCity: (v) {
                        setState(() => _city = v);
                        Navigator.pop(ctx);
                        _load(reset: true);
                      },
                      onClear: () {
                        setState(() {
                          _city = 'All Hungary';
                          _category = null;
                        });
                        Navigator.pop(ctx);
                        _load(reset: true);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
                  onPressed: () => setState(() => _grid = !_grid),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: kBrowseCategories.length,
              itemBuilder: (context, i) {
                final c = kBrowseCategories[i];
                final sel = _category == null
                    ? c.id == kTrendingCategoryId
                    : _category == c.id;
                return NuveloCategoryChip(
                  category: c,
                  selected: sel,
                  onTap: () {
                    setState(() {
                      _category = c.id == kTrendingCategoryId ? null : c.id;
                    });
                    _load(reset: true);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_items.length} ${L.recentAds}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NuveloColors.textMuted,
                        ),
                  ),
                ),
                DropdownButton<String>(
                  value: _sort,
                  dropdownColor: NuveloColors.cardBg,
                  items: const [
                    DropdownMenuItem(
                      value: 'created_at',
                      child: Text('Newest'),
                    ),
                    DropdownMenuItem(
                      value: 'popular',
                      child: Text('Recommended'),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Price ↑'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Price ↓'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _sort = v);
                    _load(reset: true);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: _loading && _items.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: List.generate(
                          5, (_) => const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: ListingCardSkeleton(),
                              )),
                    )
                  : _items.isEmpty
                      ? ListView(
                          children: [
                            EmptyState(
                              title: L.noListingsYet,
                              actionLabel: L.postAd,
                              onAction: () => context.push('/post'),
                            ),
                          ],
                        )
                      : _grid
                          ? GridView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _items.length,
                              itemBuilder: (context, i) {
                                final l = _items[i];
                                return ListingCard(
                                  listing: l,
                                  lang: lang,
                                  dense: true,
                                  onTap: () =>
                                      context.push('/listing/${l.id}'),
                                );
                              },
                            )
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(12),
                              itemCount: _items.length,
                              itemBuilder: (context, i) {
                                final l = _items[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ListingCardHorizontal(
                                    listing: l,
                                    lang: lang,
                                    onTap: () =>
                                        context.push('/listing/${l.id}'),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.city,
    required this.onCity,
    required this.onClear,
  });

  final String city;
  final ValueChanged<String> onCity;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kHungarianCities
                    .map(
                      (c) => ActionChip(
                        label: Text(c),
                        onPressed: () => onCity(c),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
