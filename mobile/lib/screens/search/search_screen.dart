import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/listing.dart';
import '../../services/listings_service.dart';
import '../../widgets/listing_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();
  final _svc = ListingsService();
  List<Listing> _results = [];
  bool _loading = false;

  Future<void> _run() async {
    setState(() => _loading = true);
    try {
      final rows = await _svc.getListings(
        search: _q.text.trim(),
        limit: 40,
      );
      setState(() => _results = rows);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: NuveloColors.darkNavy,
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: _q,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search…',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _run(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _run),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final l = _results[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListingCard(
                    listing: l,
                    lang: lang,
                    onTap: () => context.push('/listing/${l.id}'),
                  ),
                );
              },
            ),
    );
  }
}
