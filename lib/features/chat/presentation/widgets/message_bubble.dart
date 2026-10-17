import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';

/// Single chat message bubble.
///
/// Own messages align to the **right**; peer messages to the **left**
/// (absolute sides, independent of RTL text direction).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isMine,
    super.key,
  });

  final MessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm('fa');
    final textTheme = Theme.of(context).textTheme;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    final bg = isMine ? AppColors.primary : AppColors.surfaceRaised;
    final fg = isMine ? Colors.white : AppColors.ink;
    final metaColor = isMine ? Colors.white70 : AppColors.inkMuted;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMine ? 18 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 18),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
            left: isMine ? 48 : 0,
            right: isMine ? 0 : 48,
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: isMine ? null : Border.all(color: AppColors.hairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isMine ? 0.08 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  message.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: fg,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeFormat.format(message.createdAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: metaColor,
                      fontSize: 11,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isMessageRead(message.readAt) ? Icons.done_all : Icons.done,
                      size: 14,
                      color: isMessageRead(message.readAt)
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
