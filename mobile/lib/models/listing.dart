import 'dart:convert';

/// Marketplace listing aligned with `/api/listings` JSON (`_listingsDb.mapRow` / listingsApi.normalize).
class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    this.price,
    required this.city,
    this.district,
    this.condition,
    required this.photos,
    required this.sellerName,
    this.sellerPhone,
    this.sellerEmail,
    this.sellerWhatsapp = false,
    this.contactPreference,
    required this.status,
    this.userId,
    this.postedByAdmin = false,
    required this.createdAt,
    this.updatedAt,
    required this.viewCount,
    this.language = 'en',
    this.currency = 'HUF',
    this.categoryFields = const {},
    this.sellerVerified = false,
    this.featured = false,
    this.imagesRaw,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final double? price;
  final String city;
  final String? district;
  final String? condition;
  final List<String> photos;
  final String sellerName;
  final String? sellerPhone;
  final String? sellerEmail;
  final bool sellerWhatsapp;
  final String? contactPreference;
  final String status;
  final String? userId;
  final bool postedByAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int viewCount;
  final String language;
  final String currency;
  final Map<String, dynamic> categoryFields;
  final bool sellerVerified;
  final bool featured;
  final dynamic imagesRaw;

  factory Listing.fromApiJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    List<String> parseImages(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) {
        try {
          final d = jsonDecode(v);
          if (d is List) return d.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    Map<String, dynamic> parseCf(dynamic v) {
      if (v == null) return {};
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      if (v is String) {
        try {
          final d = jsonDecode(v);
          if (d is Map) return Map<String, dynamic>.from(d);
        } catch (_) {}
      }
      return {};
    }

    final pf = parseCf(json['categoryFields']);
    final loc = json['location']?.toString() ?? '';
    final district = pf['district'] ?? pf['districtLabel'];

    return Listing(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['categoryId']?.toString() ?? json['category']?.toString() ?? '',
      subcategory: pf['subcategory']?.toString(),
      price: json['price'] == null ? null : num.tryParse(json['price'].toString())?.toDouble(),
      city: loc.isNotEmpty ? loc : 'Hungary',
      district: district?.toString(),
      condition: json['condition']?.toString(),
      photos: parseImages(json['images']),
      sellerName: json['sellerName']?.toString() ?? 'Seller',
      sellerPhone: json['sellerPhone']?.toString(),
      sellerEmail: json['sellerEmail']?.toString(),
      sellerWhatsapp: json['sellerWhatsapp'] == true,
      contactPreference: json['contactPreference']?.toString(),
      status: json['status']?.toString() ?? 'approved',
      userId: json['userId']?.toString(),
      postedByAdmin: json['postedByAdmin'] == true,
      createdAt: parseDate(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      viewCount: int.tryParse(json['viewCount']?.toString() ?? '') ??
          int.tryParse(json['views']?.toString() ?? '') ??
          0,
      language: json['language']?.toString() ?? 'en',
      currency: json['currency']?.toString() ?? 'HUF',
      categoryFields: pf,
      sellerVerified: json['sellerVerified'] == true,
      featured: json['featured'] == true || json['isFeatured'] == true,
      imagesRaw: json['images'],
    );
  }

  Map<String, dynamic> toApiPayload() => {
        'title': title,
        'description': description,
        'categoryId': category,
        'price': price,
        'currency': currency,
        'condition': condition ?? 'other',
        'location': city,
        'images': photos,
        'categoryFields': categoryFields,
      };
}
