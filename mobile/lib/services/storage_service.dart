import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../core/supabase_client.dart';

class StorageService {
  /// Uploads to `listings-images` at `listings/{folderTimestamp}-{userId}/{filename}`.
  Future<String> uploadListingPhoto({
    required XFile file,
    required String userId,
    required String folderTimestamp,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      throw Exception('Image exceeds 5MB limit');
    }
    var ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (ext.isEmpty || ext.length > 5) ext = 'jpg';
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) ext = 'jpg';
    final fname =
        '${DateTime.now().millisecondsSinceEpoch}_${bytes.hashCode.abs()}.$ext';
    final storagePath = 'listings/$folderTimestamp-$userId/$fname';

    await supabase.storage.from('listings-images').uploadBinary(
          storagePath,
          bytes,
        );
    return supabase.storage.from('listings-images').getPublicUrl(storagePath);
  }

  /// Legacy path shape (listing id folder) — kept for older call sites.
  Future<String> uploadListingPhotoByListingId({
    required String listingId,
    required String filename,
    required Uint8List bytes,
  }) async {
    final path = 'listings/$listingId/$filename';
    await supabase.storage.from('listings-images').uploadBinary(path, bytes);
    return supabase.storage.from('listings-images').getPublicUrl(path);
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String ext = 'jpg',
  }) async {
    final path = 'avatars/$userId/avatar.$ext';
    await supabase.storage.from('avatars').uploadBinary(path, bytes);
    return supabase.storage.from('avatars').getPublicUrl(path);
  }
}
