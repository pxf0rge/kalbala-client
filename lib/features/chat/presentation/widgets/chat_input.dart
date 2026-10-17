import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';

/// Text input bar for sending chat messages.
class ChatInput extends StatefulWidget {
  const ChatInput({
    required this.onSend,
    this.isSending = false,
    super.key,
  });

  final Future<bool> Function(String content) onSend;
  final bool isSending;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim().isNotEmpty;
      if (next != _hasText) setState(() => _hasText = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text;
    if (content.trim().isEmpty || widget.isSending) return;

    final success = await widget.onSend(content);
    if (!mounted) return;
    if (success) {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.isSending;

    return Material(
      color: AppColors.surfaceRaised,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: TextField(
                    key: const Key('chat_input_field'),
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'پیام خود را بنویسید...',
                      hintStyle: TextStyle(color: AppColors.inkMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      counterText: '',
                    ),
                    textInputAction: TextInputAction.send,
                    maxLength: kMaxMessageLength,
                    maxLines: 5,
                    minLines: 1,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: canSend ? AppColors.primary : AppColors.secondarySoft,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: canSend ? _submit : null,
                  tooltip: 'ارسال',
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: canSend ? Colors.white : AppColors.inkMuted,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
