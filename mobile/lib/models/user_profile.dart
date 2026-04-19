class UserProfile {
  UserProfile({
    required this.id,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.role,
    this.city,
    this.avatarUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String role;
  final String? city;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  factory UserProfile.fromSupabase(Map<String, dynamic> json, {Map<String, dynamic>? authMeta}) {
    DateTime ts(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    final meta = authMeta ?? {};
    final email = meta['email']?.toString() ?? json['email']?.toString();

    return UserProfile(
      id: json['id']?.toString() ?? '',
      displayName:
          json['display_name']?.toString() ?? email?.split('@').first ?? 'User',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: email,
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'buyer',
      city: json['city']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      isVerified: json['is_verified'] == true,
      createdAt: ts(json['created_at']),
    );
  }

  Map<String, dynamic> toUpsertRow() => {
        'display_name': displayName,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': role,
        'city': city,
        'avatar_url': avatarUrl,
      };
}
