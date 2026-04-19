import 'dart:typed_data';

import '../core/supabase_client.dart';

class StorageService {
  /// Returns public URL for uploaded listing image.
  Future<String> uploadListingPhoto({
    required String listingId,
    required String filename,
    required Uint8List bytes,
  }) async {
    final path = 'listings/$listingId/$filename';
    await supabase.storage.from('listings-images').uploadBinary(
          path,
          bytes,
        );
    return supabase.storage.from('listings-images').getPublicUrl(path);
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String ext = 'jpg',
  }) async {
    final path = 'avatars/$userId/avatar.$ext';
    await supabase.storage.from('avatars').uploadBinary(
          path,
          bytes,
        );
    return supabase.storage.from('avatars').getPublicUrl(path);
  }
}
