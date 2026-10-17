/// Maximum ticket message length (matches DB constraint).
const int kMaxTicketMessageLength = 2000;

/// Ticket lifecycle status.
enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get dbValue => switch (this) {
        TicketStatus.open => 'open',
        TicketStatus.inProgress => 'in_progress',
        TicketStatus.resolved => 'resolved',
        TicketStatus.closed => 'closed',
      };

  String get label => switch (this) {
        TicketStatus.open => 'باز',
        TicketStatus.inProgress => 'در حال بررسی',
        TicketStatus.resolved => 'حل شده',
        TicketStatus.closed => 'بسته شده',
      };

  static TicketStatus fromDb(String value) => switch (value) {
        'open' => TicketStatus.open,
        'in_progress' => TicketStatus.inProgress,
        'resolved' => TicketStatus.resolved,
        'closed' => TicketStatus.closed,
        _ => TicketStatus.open,
      };

  bool get isClosed => this == TicketStatus.resolved || this == TicketStatus.closed;
}

class SupportTicketEntity {
  const SupportTicketEntity({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  final String id;
  final String subject;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
}

class TicketMessageEntity {
  const TicketMessageEntity({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.content,
    required this.isAdminReply,
    required this.createdAt,
    this.attachmentPath,
  });

  final String id;
  final String ticketId;
  final String senderId;
  final String content;
  final String? attachmentPath;
  final bool isAdminReply;
  final DateTime createdAt;
}

class TicketDetailEntity {
  const TicketDetailEntity({
    required this.ticket,
    required this.messages,
  });

  final SupportTicketEntity ticket;
  final List<TicketMessageEntity> messages;
}

class CreateTicketInput {
  const CreateTicketInput({
    required this.subject,
    required this.content,
    this.attachmentPath,
  });

  final String subject;
  final String content;
  final String? attachmentPath;
}

class SendTicketMessageInput {
  const SendTicketMessageInput({
    required this.ticketId,
    required this.content,
    this.attachmentPath,
  });

  final String ticketId;
  final String content;
  final String? attachmentPath;
}

class CreateTicketResult {
  const CreateTicketResult({
    required this.ticketId,
    required this.messageId,
  });

  final String ticketId;
  final String messageId;
}

/// Validates ticket creation input.
String? validateCreateTicketInput(CreateTicketInput input) {
  final subject = input.subject.trim();
  final content = input.content.trim();

  if (subject.length < 3 || subject.length > 200) {
    return 'موضوع باید بین ۳ تا ۲۰۰ کاراکتر باشد.';
  }
  if (content.isEmpty || content.length > kMaxTicketMessageLength) {
    return 'پیام باید بین ۱ تا $kMaxTicketMessageLength کاراکتر باشد.';
  }
  return null;
}

/// Validates outgoing ticket message content.
String? validateTicketMessageContent(String content) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) return 'پیام نمی‌تواند خالی باشد.';
  if (trimmed.length > kMaxTicketMessageLength) {
    return 'پیام حداکثر $kMaxTicketMessageLength کاراکتر می‌تواند باشد.';
  }
  return null;
}

bool isTicketMessageFromCurrentUser({
  required String senderId,
  required String currentUserId,
}) =>
    senderId == currentUserId;
