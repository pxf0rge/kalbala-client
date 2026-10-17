import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';
import 'package:rahmani_project/features/chat/presentation/widgets/unread_badge.dart';

/// Conversation preview tile for list screen.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm('fa');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            conversation.otherPartyName.isNotEmpty
                ? conversation.otherPartyName.substring(0, 1)
                : '?',
          ),
        ),
        title: Text(conversation.otherPartyName),
        subtitle: Text(
          conversation.lastMessagePreview ?? 'بدون پیام',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (conversation.lastMessageAt != null)
              Text(
                timeFormat.format(conversation.lastMessageAt!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            UnreadBadge(count: conversation.unreadCount),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
