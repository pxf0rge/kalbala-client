import 'package:flutter/material.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';

/// Input bar for sending ticket messages.
class TicketMessageInput extends StatefulWidget {
  const TicketMessageInput({
    required this.onSend,
    this.isSending = false,
    super.key,
  });

  final Future<bool> Function(String content) onSend;
  final bool isSending;

  @override
  State<TicketMessageInput> createState() => _TicketMessageInputState();
}

class _TicketMessageInputState extends State<TicketMessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text;
    if (content.trim().isEmpty || widget.isSending) return;

    final success = await widget.onSend(content);
    if (!mounted) return;
    if (success) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('ticket_message_input'),
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'پیام خود را بنویسید...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                maxLength: kMaxTicketMessageLength,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: widget.isSending ? null : _submit,
              icon: widget.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
