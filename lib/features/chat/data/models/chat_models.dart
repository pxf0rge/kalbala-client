import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';

class ChatModels {
  static ConversationEntity conversationFromJson(Map<String, dynamic> json) {
    return ConversationEntity(
      id: json['conversation_id'] as String,
      boothId: json['booth_id'] as String,
      boothName: json['booth_name'] as String? ?? '',
      boothSlug: json['booth_slug'] as String? ?? '',
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      otherPartyName: json['other_party_name'] as String? ?? '',
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      lastMessagePreview: json['last_message_preview'] as String?,
    );
  }

  static MessageEntity messageFromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
    );
  }
}
