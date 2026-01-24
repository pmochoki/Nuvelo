class Category {
  final String id;
  final String name;

  const Category({required this.id, required this.name});
}

class SavedSearch {
  final String query;
  final String? categoryId;
  final String? location;
  final num? minPrice;
  final num? maxPrice;

  const SavedSearch({
    required this.query,
    this.categoryId,
    this.location,
    this.minPrice,
    this.maxPrice
  });
}

class UserProfile {
  final String id;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final bool emailVerified;
  final bool phoneVerified;
  final bool banned;
  final String memberSince;
  final int listingCount;
  final int approvedListings;

  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.phoneVerified,
    required this.banned,
    required this.memberSince,
    required this.listingCount,
    required this.approvedListings
  });
}

class Listing {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String location;
  final int? price;
  final String currency;
  final String priceLabel;
  final String condition;
  final String sellerId;
  final String sellerName;
  final Map<String, String> categoryFields;
  final String status;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.price,
    required this.currency,
    required this.priceLabel,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.categoryFields,
    required this.status
  });
}

class Conversation {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String createdAt;

  const Conversation({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt
  });
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String createdAt;
  final String? readAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.readAt
  });
}
