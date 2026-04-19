import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/listing.dart';

String resolveListingsApiBase() {
  const fromEnv = String.fromEnvironment('NUVELO_API_BASE');
  if (fromEnv.isNotEmpty) {
    return fromEnv.replaceAll(RegExp(r'/+$'), '');
  }
  return kDefaultListingsApiBase;
}

/// Loads public listings via the same HTTPS API as nuvelo.one (`/api/listings`).
class ListingsService {
  ListingsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = resolveListingsApiBase();
    final u = Uri.parse(base);
    return u.replace(
      path: '${u.path}$path'.replaceAll(RegExp(r'//+'), '/'),
      queryParameters: query,
    );
  }

  Future<List<Listing>> getListings({
    String? category,
    String? city,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? condition,
    bool? verifiedOnly,
    String sortBy = 'created_at',
    int limit = 20,
    int offset = 0,
    String? userId,
  }) async {
    final q = <String, String>{};
    if (search != null && search.trim().isNotEmpty) q['query'] = search.trim();
    if (category != null &&
        category.isNotEmpty &&
        category != kTrendingCategoryId) {
      q['categoryId'] = category;
    }
    if (city != null &&
        city.isNotEmpty &&
        city.toLowerCase() != 'all hungary') {
      q['location'] = city;
    }
    if (minPrice != null) q['minPrice'] = minPrice.toString();
    if (maxPrice != null) q['maxPrice'] = maxPrice.toString();
    if (userId != null) q['userId'] = userId;

    final res = await _client.get(_uri('/listings', q));
    if (res.statusCode != 200) {
      throw Exception('listings_http_${res.statusCode}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    var rows = list
        .map((e) => Listing.fromApiJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // Client-side filters API does not cover (verified, condition band).
    if (condition != null &&
        condition.isNotEmpty &&
        condition != 'all') {
      rows = rows
          .where((l) =>
              (l.condition ?? '').toLowerCase() == condition.toLowerCase())
          .toList();
    }
    if (verifiedOnly == true) {
      rows = rows.where((l) => l.sellerVerified).toList();
    }

    rows.sort((a, b) {
      switch (sortBy) {
        case 'price_asc':
          return (a.price ?? -1).compareTo(b.price ?? -1);
        case 'price_desc':
          return (b.price ?? -1).compareTo(a.price ?? -1);
        case 'popular':
          return b.viewCount.compareTo(a.viewCount);
        case 'created_at':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    if (offset >= rows.length) return [];
    final end = (offset + limit).clamp(0, rows.length);
    return rows.sublist(offset, end);
  }

  Future<Listing?> getListing(String id) async {
    final res = await _client.get(_uri('/listings/$id'));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('listing_http_${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return Listing.fromApiJson(map);
  }

  Future<String> createListing(
    Map<String, dynamic> data, {
    required String userId,
  }) async {
    final payload = Map<String, dynamic>.from(data);
    payload['userId'] = userId;
    final res = await _client.post(
      _uri('/listings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 201) {
      throw Exception('create_listing_${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return map['id']?.toString() ?? '';
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    final res = await _client.patch(
      _uri('/listings/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      throw Exception('update_listing_${res.statusCode}');
    }
  }

  Future<void> deleteListing(String id) async {
    final res = await _client.delete(_uri('/listings/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('delete_listing_${res.statusCode}');
    }
  }

  Future<void> toggleSaved(String listingId) async {
    // Persisted locally — see SavedListingsStore until `saved_listings` exists.
    await SavedListingsStore.instance.toggle(listingId);
  }

  Future<List<Listing>> getSavedListings() async {
    final ids = await SavedListingsStore.instance.ids();
    final out = <Listing>[];
    for (final id in ids) {
      final l = await getListing(id);
      if (l != null) out.add(l);
    }
    return out;
  }

  Future<void> incrementViews(String listingId) async {
    // Server-side view tracking may be added later; keep hook for UI calls.
    await Future<void>.delayed(Duration.zero);
  }
}

/// Local favourites store (replacing DB until `saved_listings` is wired).
class SavedListingsStore {
  SavedListingsStore._();
  static final SavedListingsStore instance = SavedListingsStore._();

  Future<void> toggle(String listingId) async {
    final prefs = await SharedPreferencesBridge.instance.prefs();
    final raw = prefs.getStringList('saved_listing_ids') ?? [];
    final set = raw.toSet();
    if (set.contains(listingId)) {
      set.remove(listingId);
    } else {
      set.add(listingId);
    }
    await prefs.setStringList('saved_listing_ids', set.toList());
  }

  Future<bool> isSaved(String listingId) async {
    final prefs = await SharedPreferencesBridge.instance.prefs();
    final raw = prefs.getStringList('saved_listing_ids') ?? [];
    return raw.contains(listingId);
  }

  Future<List<String>> ids() async {
    final prefs = await SharedPreferencesBridge.instance.prefs();
    return prefs.getStringList('saved_listing_ids') ?? [];
  }
}

/// Lazy prefs singleton for services without BuildContext.
class SharedPreferencesBridge {
  SharedPreferencesBridge._();
  static final SharedPreferencesBridge instance = SharedPreferencesBridge._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> prefs() async =>
      _prefs ??= await SharedPreferences.getInstance();
}
