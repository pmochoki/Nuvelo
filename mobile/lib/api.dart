import "dart:convert";

import "package:http/http.dart" as http;

import "models.dart";

const bool useLocalApi = false;
const String localBaseUrl = "http://10.0.2.2:4000";
const String renderBaseUrl = "https://nuvelo-backend.onrender.com";

class ApiService {
  const ApiService();

  String get baseUrl => useLocalApi ? localBaseUrl : renderBaseUrl;

  Future<UserProfile> login({
    required String name,
    required String role,
    String? email,
    String? phone,
    String? otp
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "role": role,
        "email": email,
        "phone": phone,
        "otp": otp
      })
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to sign in");
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapUserProfile(data);
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load categories");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => Category(id: item["id"], name: item["name"]))
        .toList();
  }

  Future<List<Listing>> fetchListings({
    String? query,
    String? categoryId,
    String? location,
    String? status,
    String? userId,
    String? viewerId
  }) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) {
      params["query"] = query;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      params["categoryId"] = categoryId;
    }
    if (location != null && location.isNotEmpty) {
      params["location"] = location;
    }
    if (status != null && status.isNotEmpty) {
      params["status"] = status;
    }
    if (userId != null && userId.isNotEmpty) {
      params["userId"] = userId;
    }
    if (viewerId != null && viewerId.isNotEmpty) {
      params["viewerId"] = viewerId;
    }
    final uri = Uri.parse("$baseUrl/listings").replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed to load listings");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map(_mapListing).toList();
  }

  Future<List<Conversation>> fetchConversations(String userId) async {
    final uri = Uri.parse("$baseUrl/conversations")
        .replace(queryParameters: {"userId": userId});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed to load conversations");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map(_mapConversation).toList();
  }

  Future<Conversation> createConversation({
    required String listingId,
    required String buyerId,
    required String sellerId
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "listingId": listingId,
        "buyerId": buyerId,
        "sellerId": sellerId
      })
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to create conversation");
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapConversation(data);
  }

  Future<List<Message>> fetchMessages(String conversationId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/conversations/$conversationId/messages"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load messages");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map(_mapMessage).toList();
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String text
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations/$conversationId/messages"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"senderId": senderId, "text": text})
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to send message");
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapMessage(data);
  }

  Future<void> markConversationRead({
    required String conversationId,
    required String userId
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations/$conversationId/mark-read"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId})
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to mark messages read");
    }
  }

  Future<List<String>> fetchFavorites(String userId) async {
    final uri =
        Uri.parse("$baseUrl/favorites").replace(queryParameters: {"userId": userId});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed to load favorites");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => (item as Map<String, dynamic>)["listingId"] as String)
        .toList();
  }

  Future<void> addFavorite({
    required String userId,
    required String listingId
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/favorites"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "listingId": listingId})
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to add favorite");
    }
  }

  Future<void> removeFavorite({
    required String userId,
    required String listingId
  }) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/favorites"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "listingId": listingId})
    );
    if (response.statusCode != 204) {
      throw Exception("Failed to remove favorite");
    }
  }

  Future<List<SavedSearch>> fetchSavedSearches(String userId) async {
    final uri = Uri.parse("$baseUrl/saved-searches")
        .replace(queryParameters: {"userId": userId});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed to load saved searches");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map(_mapSavedSearch).toList();
  }

  Future<SavedSearch> saveSearch({
    required String userId,
    required SavedSearch search
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/saved-searches"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "query": search.query,
        "categoryId": search.categoryId,
        "location": search.location,
        "minPrice": search.minPrice,
        "maxPrice": search.maxPrice
      })
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to save search");
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapSavedSearch(data);
  }

  Future<List<String>> fetchBlocks(String userId) async {
    final uri =
        Uri.parse("$baseUrl/blocks").replace(queryParameters: {"userId": userId});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Failed to load blocks");
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => (item as Map<String, dynamic>)["blockedId"] as String)
        .toList();
  }

  Future<void> blockUser({
    required String blockerId,
    required String blockedId
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/blocks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"blockerId": blockerId, "blockedId": blockedId})
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to block user");
    }
  }

  Future<void> createReport({
    required String type,
    required String targetId,
    required String reason,
    required String reporterId
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reports"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "type": type,
        "targetId": targetId,
        "reason": reason,
        "reporterId": reporterId
      })
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to submit report");
    }
  }

  Future<Listing> createListing({
    required String title,
    required String description,
    required String categoryId,
    required num? price,
    required String currency,
    required String location,
    required List<String> images,
    required String condition,
    required Map<String, String> categoryFields,
    required String userId
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/listings"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "description": description,
        "categoryId": categoryId,
        "price": price,
        "currency": currency,
        "location": location,
        "images": images,
        "condition": condition,
        "categoryFields": categoryFields,
        "userId": userId
      })
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to create listing");
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapListing(data);
  }

  UserProfile _mapUserProfile(Map<String, dynamic> data) {
    return UserProfile(
      id: data["id"] ?? "",
      name: data["name"] ?? "",
      role: data["role"] ?? "",
      email: data["email"],
      phone: data["phone"],
      emailVerified: data["emailVerified"] ?? false,
      phoneVerified: data["phoneVerified"] ?? false,
      banned: data["banned"] ?? false,
      memberSince: data["memberSince"] ?? data["createdAt"] ?? "",
      listingCount: data["listingCount"] ?? 0,
      approvedListings: data["approvedListings"] ?? 0
    );
  }

  SavedSearch _mapSavedSearch(dynamic item) {
    final Map<String, dynamic> raw = item as Map<String, dynamic>;
    return SavedSearch(
      query: raw["query"] ?? "",
      categoryId: raw["categoryId"],
      location: raw["location"],
      minPrice: raw["minPrice"],
      maxPrice: raw["maxPrice"]
    );
  }

  Conversation _mapConversation(dynamic item) {
    final Map<String, dynamic> raw = item as Map<String, dynamic>;
    return Conversation(
      id: raw["id"] ?? "",
      listingId: raw["listingId"] ?? "",
      buyerId: raw["buyerId"] ?? "",
      sellerId: raw["sellerId"] ?? "",
      createdAt: raw["createdAt"] ?? ""
    );
  }

  Message _mapMessage(dynamic item) {
    final Map<String, dynamic> raw = item as Map<String, dynamic>;
    return Message(
      id: raw["id"] ?? "",
      conversationId: raw["conversationId"] ?? "",
      senderId: raw["senderId"] ?? "",
      text: raw["text"] ?? "",
      createdAt: raw["createdAt"] ?? "",
      readAt: raw["readAt"]
    );
  }

  Listing _mapListing(dynamic item) {
    final Map<String, dynamic> raw = item as Map<String, dynamic>;
    final num? priceValue = raw["price"] as num?;
    final int? price = priceValue?.toInt();
    final String currency = raw["currency"] ?? "HUF";
    final String priceLabel =
        price == null ? "Contact for price" : "$currency $price";
    final Map<String, dynamic> rawFields =
        (raw["categoryFields"] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, String> fields = rawFields.map(
      (key, value) => MapEntry(key, value.toString())
    );
    final String sellerId = raw["userId"] ?? "unknown";
    return Listing(
      id: raw["id"] ?? "",
      title: raw["title"] ?? "",
      description: raw["description"] ?? "",
      categoryId: raw["categoryId"] ?? "",
      location: raw["location"] ?? "",
      price: price,
      currency: currency,
      priceLabel: priceLabel,
      condition: raw["condition"] ?? "good",
      sellerId: sellerId,
      sellerName: raw["sellerName"] ?? "Seller",
      categoryFields: fields,
      status: raw["status"] ?? "pending"
    );
  }
}
