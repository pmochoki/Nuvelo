import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/listings_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _page = PageController();
  int _step = 0;

  String? _category;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  bool _priceOnRequest = false;
  String _location = 'Budapest';
  String _condition = 'used';
  final _svc = ListingsService();
  bool _submitting = false;

  @override
  void dispose() {
    _page.dispose();
    _title.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  bool get _validStep0 =>
      _category != null &&
      _title.text.trim().length >= 5 &&
      _description.text.trim().length >= 20;

  Future<void> _submit() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _submitting = true);
    try {
      final payload = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'categoryId': _category,
        'price': _priceOnRequest
            ? null
            : double.tryParse(_price.text.trim().replaceAll(',', '')),
        'currency': 'HUF',
        'condition': _condition,
        'location': _location,
        'images': <String>[],
        'categoryFields': <String, dynamic>{},
      };
      await _svc.createListing(payload, userId: uid);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Submitted'),
          content: const Text(
            'Your ad is under review! We will notify you when it goes live.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/profile/my-ads');
              },
              child: const Text('View my ads'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _step = 0;
                  _category = null;
                  _title.clear();
                  _description.clear();
                  _price.clear();
                });
                _page.jumpToPage(0);
              },
              child: const Text('Post another'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not publish')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(L.postAd)),
        body: EmptyState(
          title: L.signInTitle,
          actionLabel: L.continueBtn,
          onAction: () => context.push('/signin?from=/post'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NuveloColors.darkNavy,
      appBar: AppBar(
        title: Text('${L.postAd} · ${_step + 1}/3'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Category',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kPostCategories.map((c) {
                        return NuveloCategoryChip(
                          category: c,
                          selected: _category == c.id,
                          onTap: () => setState(() => _category = c.id),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _description,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 6,
                    ),
                    SwitchListTile(
                      title: Text(L.priceOnRequest),
                      value: _priceOnRequest,
                      onChanged: (v) => setState(() => _priceOnRequest = v),
                    ),
                    if (!_priceOnRequest)
                      TextField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'HUF'),
                      ),
                    DropdownButtonFormField<String>(
                      initialValue: _location,
                      decoration: InputDecoration(labelText: L.locationAllHungary),
                      items: kHungarianCities
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _location = v ?? _location),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('New')),
                        DropdownMenuItem(value: 'used', child: Text('Used')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) =>
                          setState(() => _condition = v ?? _condition),
                    ),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Photo uploads: tap “Next” on a device build with photos — Step 2 placeholder.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_title.text, style: Theme.of(context).textTheme.titleLarge),
                    Text(_description.text),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          !_validStep0 || _submitting ? null : _submit,
                      child: Text(L.postAd),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: () {
                      _page.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                      setState(() => _step -= 1);
                    },
                    child: const Text('Back'),
                  ),
                const Spacer(),
                if (_step < 2)
                  FilledButton(
                    onPressed: !_validStep0 && _step == 0
                        ? null
                        : () {
                            _page.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                            setState(() => _step += 1);
                          },
                    child: Text(_step == 0 ? L.next : L.next),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
