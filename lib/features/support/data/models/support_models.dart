import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';

abstract final class SupportModels {
  static SupportTicketEntity ticketFromJson(Map<String, dynamic> json) {
    return SupportTicketEntity(
      id: json['id'] as String,
      subject: json['subject'] as String,
      status: TicketStatus.fromDb(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }

  static SupportTicketEntity ticketSummaryFromJson(Map<String, dynamic> json) {
    return SupportTicketEntity(
      id: json['id'] as String,
      subject: json['subject'] as String,
      status: TicketStatus.fromDb(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static TicketMessageEntity messageFromJson(
    Map<String, dynamic> json, {
    required String ticketId,
  }) {
    return TicketMessageEntity(
      id: json['id'] as String,
      ticketId: ticketId,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      attachmentPath: json['attachment_url'] as String?,
      isAdminReply: json['is_admin_reply'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static TicketDetailEntity detailFromJson(Map<String, dynamic> json) {
    final ticketJson = Map<String, dynamic>.from(json['ticket'] as Map);
    final ticket = ticketSummaryFromJson(ticketJson);
    final messagesJson = json['messages'] as List<dynamic>? ?? [];

    return TicketDetailEntity(
      ticket: ticket,
      messages: messagesJson
          .map(
            (item) => messageFromJson(
              Map<String, dynamic>.from(item as Map),
              ticketId: ticket.id,
            ),
          )
          .toList(),
    );
  }

  static CreateTicketResult createResultFromJson(Map<String, dynamic> json) {
    return CreateTicketResult(
      ticketId: json['ticket_id'] as String,
      messageId: json['message_id'] as String,
    );
  }
}
