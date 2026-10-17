/// Maximum text message length (matches DB constraint).
const int kMaxMessageLength = 2000;

class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.boothId,
    required this.boothName,
    required this.boothSlug,
    required this.buyerId,
    required this.sellerId,
    required this.otherPartyName,
    required this.unreadCount,
    this.lastMessageAt,
    this.lastMessagePreview,
  });

  final String id;
  final String boothId;
  final String boothName;
  final String boothSlug;
  final String buyerId;
  final String sellerId;
  final String otherPartyName;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
}

class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;

  MessageEntity copyWith({
    DateTime? readAt,
  }) {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

/// Validates outgoing chat message content.
String? validateMessageContent(String content) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) return 'پیام نمی‌تواند خالی باشد.';
  if (trimmed.length > kMaxMessageLength) {
    return 'پیام حداکثر $kMaxMessageLength کاراکتر می‌تواند باشد.';
  }
  return null;
}

/// Whether the current user sent this message.
bool isMessageFromCurrentUser({
  required String senderId,
  required String currentUserId,
}) =>
    senderId == currentUserId;

/// Whether a message has been read by the recipient.
bool isMessageRead(DateTime? readAt) => readAt != null;
