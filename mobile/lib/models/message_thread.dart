class MessageThread {
  MessageThread({
    required this.id,
    required this.listingId,
    required this.listingOwnerId,
    required this.participantLow,
    required this.participantHigh,
    this.listingTitleSnapshot,
    this.listingThumbUrl,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.lastMessageFrom,
    required this.createdAt,
    this.unreadCount = 0,
  });

  final String id;
  final String listingId;
  final String listingOwnerId;
  final String participantLow;
  final String participantHigh;
  final String? listingTitleSnapshot;
  final String? listingThumbUrl;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final String? lastMessageFrom;
  final DateTime createdAt;
  final int unreadCount;

  factory MessageThread.fromSupabase(Map<String, dynamic> json) {
    DateTime? opt(String? s) =>
        s == null ? null : DateTime.tryParse(s);

    return MessageThread(
      id: json['id']?.toString() ?? '',
      listingId: json['listing_id']?.toString() ?? '',
      listingOwnerId: json['listing_owner_id']?.toString() ?? '',
      participantLow: json['participant_low']?.toString() ?? '',
      participantHigh: json['participant_high']?.toString() ?? '',
      listingTitleSnapshot: json['listing_title_snapshot']?.toString(),
      listingThumbUrl: json['listing_thumb_url']?.toString(),
      lastMessageAt: opt(json['last_message_at']?.toString()),
      lastMessagePreview: json['last_message_preview']?.toString(),
      lastMessageFrom: json['last_message_from']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
    );
  }
}
