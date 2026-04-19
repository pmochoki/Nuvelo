import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuvelo_marketplace/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../services/listings_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/nuvelo_screen.dart';

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
  final _picker = ImagePicker();
  bool _submitting = false;

  DateTime _availabilityDate = DateTime.now();
  Duration _contactTime = const Duration(hours: 9, minutes: 0);

  final List<Uint8List> _imageBytes = [];

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

  Future<void> _pickPhotos() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    for (final x in files) {
      final b = await x.readAsBytes();
      if (b.length > 5 * 1024 * 1024) continue;
      setState(() => _imageBytes.add(b));
    }
  }

  void _removePhoto(int i) {
    setState(() => _imageBytes.removeAt(i));
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
        'images': <String>[],
        'categoryFields': <String, dynamic>{
          'availabilityDate': _availabilityDate.toIso8601String(),
          'preferredContactMinutes':
              _contactTime.inMinutes.remainder(1440).toString(),
        },
      };
      final id = await _svc.createListing(payload, userId: uid);
      final urls = <String>[];
      for (var i = 0; i < _imageBytes.length; i++) {
        final url = await StorageService().uploadListingPhoto(
          listingId: id,
          filename: 'photo_$i.jpg',
          bytes: _imageBytes[i],
        );
        urls.add(url);
      }
      if (urls.isNotEmpty && id.isNotEmpty) {
        await _svc.updateListing(id, {'images': urls});
      }
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
                  _imageBytes.clear();
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
                      decoration: const InputDecoration(labelText: 'Description'),
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
                    Text(
                      'Photos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Up to 8 images, 5MB each.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: NuveloColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _pickPhotos,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Add photos'),
                    ),
                    const SizedBox(height: 16),
                    if (_imageBytes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No photos yet — optional, but listings with photos get more replies.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: NuveloColors.textMuted,
                              ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _imageBytes.length,
                        itemBuilder: (context, i) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _imageBytes[i],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton.filledTonal(
                                  iconSize: 20,
                                  onPressed: () => _removePhoto(i),
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            ],
                          );
                        },
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
                    Text(
                      '${_imageBytes.length} photo(s) · ${_availabilityDate.toIso8601String().split('T').first}',
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
                    onPressed: !_validStep0 && _step == 0
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
}
