import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme.dart';
import '../../services/storage_service.dart';

/// Eight fixed slots for listing photos: slot 0 is cover. Max 8 images, 5MB each.
/// Uploads to Supabase `listings-images` under `listings/{timestamp}-{userId}/…`.
class PostPhotosScreen extends StatefulWidget {
  const PostPhotosScreen({
    super.key,
    required this.userId,
    required this.folderTimestamp,
    required this.onUrlsChanged,
    this.onUploadingChanged,
  });

  final String userId;
  /// Single session folder key (e.g. milliseconds since epoch) for all uploads.
  final String folderTimestamp;
  final ValueChanged<List<String>> onUrlsChanged;
  final ValueChanged<bool>? onUploadingChanged;

  @override
  State<PostPhotosScreen> createState() => _PostPhotosScreenState();
}

class _Slot {
  Uint8List? preview;
  String? url;
  bool uploading = false;
  bool error = false;
}

class _PostPhotosScreenState extends State<PostPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storage = StorageService();
  final List<_Slot> _slots = List.generate(8, (_) => _Slot());

  List<String> get _urls =>
      _slots.map((s) => s.url).whereType<String>().toList();

  void _notifyUrls() {
    widget.onUrlsChanged(_urls);
  }

  void _notifyUploading() {
    final busy = _slots.any((s) => s.uploading);
    widget.onUploadingChanged?.call(busy);
  }

  Future<bool> _ensurePermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final s = await Permission.camera.request();
      if (!s.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required')),
          );
        }
        return false;
      }
      return true;
    }
    final photos = await Permission.photos.request();
    if (photos.isGranted) return true;
    final storage = await Permission.storage.request();
    if (storage.isGranted) return true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo library permission is required'),
        ),
      );
    }
    return false;
  }

  Future<void> _pickForSlot(int index, ImageSource source) async {
    if (!await _ensurePermissions(source)) return;

    final x = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 4096,
      maxHeight: 4096,
    );
    if (x == null) return;

    final bytes = await x.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be 5MB or smaller')),
        );
      }
      return;
    }

    setState(() {
      _slots[index].preview = bytes;
      _slots[index].error = false;
      _slots[index].uploading = true;
      _slots[index].url = null;
    });
    _notifyUploading();

    try {
      final url = await _storage.uploadListingPhoto(
        file: x,
        userId: widget.userId,
        folderTimestamp: widget.folderTimestamp,
      );
      if (!mounted) return;
      setState(() {
        _slots[index].url = url;
        _slots[index].uploading = false;
      });
      _notifyUrls();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _slots[index].uploading = false;
        _slots[index].error = true;
        _slots[index].preview = null;
        _slots[index].url = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed — tap slot to retry')),
      );
      _notifyUrls();
    } finally {
      _notifyUploading();
    }
  }

  Future<void> _openSlotPicker(int index) async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: NuveloColors.cardBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (choice != null) await _pickForSlot(index, choice);
  }

  void _clearSlot(int index) {
    setState(() {
      _slots[index] = _Slot();
    });
    _notifyUrls();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyUrls();
      _notifyUploading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Photos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Up to 8 images · 5MB each · First slot is cover',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: NuveloColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final s = _slots[index];
            return Material(
              color: NuveloColors.deepCard,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: s.uploading ? null : () => _openSlotPicker(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (s.preview != null && s.preview!.isNotEmpty)
                      Image.memory(
                        s.preview!,
                        fit: BoxFit.cover,
                      )
                    else if (s.error)
                      Center(
                        child: Icon(
                          Icons.refresh,
                          color: NuveloColors.primaryOrange,
                          size: 36,
                        ),
                      )
                    else
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: NuveloColors.textMuted,
                        size: 32,
                      ),
                    if (index == 0 &&
                        ((s.preview != null && s.preview!.isNotEmpty) ||
                            s.url != null))
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NuveloColors.primaryOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Cover',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    if (s.uploading)
                      Container(
                        color: NuveloColors.darkNavy.withValues(alpha: 0.55),
                        child: const Center(
                          child: SizedBox(
                            height: 32,
                            width: 32,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    if (s.preview != null && !s.uploading && s.url != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                NuveloColors.darkNavy.withValues(alpha: 0.75),
                          ),
                          iconSize: 18,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => _clearSlot(index),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
