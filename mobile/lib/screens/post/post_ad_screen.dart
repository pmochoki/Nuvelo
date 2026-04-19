import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/listings_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/nuvelo_screen.dart';
import 'post_category_fields.dart';
import 'post_photos_screen.dart';

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

  DateTime _availabilityDate = DateTime.now();
  Duration _contactTime = const Duration(hours: 9, minutes: 0);

  /// Folder segment for Supabase path `listings/{ts}-{userId}/…`.
  String _listingPhotoFolderTs =
      DateTime.now().millisecondsSinceEpoch.toString();

  /// Bumps to reset [PostPhotosScreen] state after “Post another”.
  int _photoSession = 0;

  List<String> _photoUrls = [];
  bool _photosUploading = false;

  Map<String, dynamic> _categoryExtras = {};

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

  Future<void> _pickListingDate(BuildContext context) async {
    var picked = _availabilityDate;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        color: NuveloColors.cardBg,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                CupertinoButton(
                  onPressed: () {
                    setState(() => _availabilityDate = picked);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: picked,
                minimumDate: DateTime.now().subtract(const Duration(days: 365)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 2)),
                onDateTimeChanged: (d) => picked = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickContactTime(BuildContext context) async {
    var d = _contactTime;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 260,
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        color: NuveloColors.cardBg,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () {
                  setState(() => _contactTime = d);
                  Navigator.pop(ctx);
                },
                child: const Text('Done'),
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: d,
                onTimerDurationChanged: (v) => d = v,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(AppLocalizations L) async {
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
        'images': _photoUrls,
        'categoryFields': () {
          final cf = <String, dynamic>{
            'availabilityDate': _availabilityDate.toIso8601String(),
            'preferredContactMinutes':
                _contactTime.inMinutes.remainder(1440).toString(),
          };
          cf.addAll(_categoryExtras);
          cf.removeWhere((_, v) => v == null);
          return cf;
        }(),
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
                  _photoUrls = [];
                  _categoryExtras = {};
                  _listingPhotoFolderTs =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  _photoSession++;
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
        SnackBar(content: Text(L.couldNotLoad)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _formatHm(Duration d) {
    final h = d.inHours.remainder(24).toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      return NuveloScreen(
        safeTop: false,
        appBar: AppBar(title: Text(L.postAd)),
        child: EmptyState(
          title: L.signInTitle,
          actionLabel: L.continueBtn,
          onAction: () => context.push('/signin?from=/post'),
        ),
      );
    }

    return NuveloScreen(
      safeTop: false,
      appBar: AppBar(
        title: Text('${L.postAd} · ${_step + 1}/3'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      child: Column(
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
                      decoration:
                          const InputDecoration(labelText: 'Description'),
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
                      decoration:
                          InputDecoration(labelText: L.locationAllHungary),
                      items: kHungarianCities
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _location = v ?? _location),
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
                    PostCategoryFieldsSection(
                      categoryId: _category,
                      availabilityDate: _availabilityDate,
                      onAvailabilityDateChanged: (d) =>
                          setState(() => _availabilityDate = d),
                      onExtrasChanged: (m) =>
                          setState(() => _categoryExtras = m),
                    ),
                    if (_category != 'rentals') ...[
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Availability date'),
                        subtitle: Text(
                          MaterialLocalizations.of(context).formatFullDate(
                            _availabilityDate,
                          ),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () => _pickListingDate(context),
                      ),
                    ],
                    ListTile(
                      title: const Text('Preferred contact time'),
                      subtitle: Text(_formatHm(_contactTime)),
                      trailing: const Icon(Icons.schedule_outlined),
                      onTap: () => _pickContactTime(context),
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PostPhotosScreen(
                      key: ValueKey(_photoSession),
                      userId: uid,
                      folderTimestamp: _listingPhotoFolderTs,
                      onUrlsChanged: (urls) =>
                          setState(() => _photoUrls = urls),
                      onUploadingChanged: (busy) =>
                          setState(() => _photosUploading = busy),
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      _title.text,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_description.text),
                    const SizedBox(height: 16),
                    if (_photoUrls.isNotEmpty)
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photoUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  _photoUrls[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      ColoredBox(color: NuveloColors.deepCard),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (_photoUrls.isNotEmpty) const SizedBox(height: 12),
                    Text(
                      '${_photoUrls.length} photo(s) · ${_availabilityDate.toIso8601String().split('T').first}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: NuveloColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          !_validStep0 || _submitting ? null : () => _submit(L),
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
                    onPressed: !_canGoNext()
                        ? null
                        : () {
                            _page.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                            setState(() => _step += 1);
                          },
                    child: Text(L.next),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoNext() {
    if (_step == 0) return _validStep0;
    if (_step == 1) return !_photosUploading;
    return true;
  }
}
