import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/utils/image_compress_utils.dart';
import 'package:rahmani_project/core/utils/safe_image_picker.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/presentation/providers/support_provider.dart';
import 'package:rahmani_project/shared/widgets/app_upload_progress_bar.dart';

/// Form to create a new support ticket.
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageExtension;
  bool _isSubmitting = false;
  bool _isPicking = false;
  double? _uploadProgress;
  String _uploadMessage = '';

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPicking || _isSubmitting) return;
    setState(() {
      _isPicking = true;
      _uploadProgress = null;
      _uploadMessage = 'در حال آماده‌سازی تصویر…';
    });
    try {
      final file = await SafeImagePicker.pickImage(
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() {
        _uploadProgress = 0.4;
        _uploadMessage = 'در حال فشرده‌سازی…';
      });
      final bytes =
          await ImageCompressUtils.compressForUpload(await file.readAsBytes());
      final extension = file.path.split('.').last.toLowerCase();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageExtension = extension;
        _uploadProgress = 1;
        _uploadMessage = 'آماده';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
          _uploadProgress = null;
          _uploadMessage = '';
        });
      }
    }
  }

  Future<void> _submit() async {
    final userId = ref.read(authSessionProvider).valueOrNull?.user.id;
    if (userId == null) return;

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.1;
      _uploadMessage = 'در حال ثبت تیکت…';
    });

    final input = CreateTicketInput(
      subject: _subjectController.text,
      content: _contentController.text,
    );

    final createResult = await ref.read(createTicketProvider).call(input);
    if (!mounted) return;

    await createResult.fold(
      (failure) async {
        setState(() {
          _isSubmitting = false;
          _uploadProgress = null;
          _uploadMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (result) async {
        if (_imageBytes != null && _imageExtension != null) {
          setState(() {
            _uploadProgress = 0.45;
            _uploadMessage = 'در حال آپلود تصویر…';
          });
          final uploadResult = await ref.read(supportRepositoryProvider).uploadAttachment(
                userId: userId,
                ticketId: result.ticketId,
                bytes: _imageBytes!,
                fileExtension: _imageExtension!,
              );

          await uploadResult.fold(
            (failure) async {
              if (!mounted) return;
              setState(() {
                _isSubmitting = false;
                _uploadProgress = null;
                _uploadMessage = '';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            },
            (path) async {
              setState(() {
                _uploadProgress = 0.85;
                _uploadMessage = 'در حال پیوست تصویر…';
              });
              final attachResult = await ref.read(supportRepositoryProvider).setMessageAttachment(
                    messageId: result.messageId,
                    attachmentPath: path,
                  );
              if (!mounted) return;
              setState(() {
                _isSubmitting = false;
                _uploadProgress = null;
                _uploadMessage = '';
              });
              attachResult.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failure.message)),
                ),
                (_) => _onSuccess(result.ticketId),
              );
            },
          );
        } else {
          setState(() {
            _isSubmitting = false;
            _uploadProgress = null;
            _uploadMessage = '';
          });
          _onSuccess(result.ticketId);
        }
      },
    );
  }

  void _onSuccess(String ticketId) {
    ref.invalidate(myTicketsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تیکت پشتیبانی ثبت شد.')),
    );
    context.go(RouteNames.ticketDetail(ticketId));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isSubmitting || _isPicking;

    return Scaffold(
      appBar: AppBar(title: const Text('تیکت جدید')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            key: const Key('ticket_subject_field'),
            controller: _subjectController,
            enabled: !busy,
            decoration: const InputDecoration(
              labelText: 'موضوع',
              border: OutlineInputBorder(),
            ),
            maxLength: 200,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('ticket_content_field'),
            controller: _contentController,
            enabled: !busy,
            decoration: const InputDecoration(
              labelText: 'پیام',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 6,
            maxLength: kMaxTicketMessageLength,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: busy ? null : _pickImage,
            icon: _isPicking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.attach_file),
            label: Text(
              _imageBytes == null ? 'افزودن تصویر (اختیاری)' : 'تصویر انتخاب شد',
            ),
          ),
          if (busy && _uploadProgress != null) ...[
            const SizedBox(height: 16),
            AppUploadProgressBar(
              progress: _uploadProgress!,
              message: _uploadMessage,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: Text(_isSubmitting ? 'در حال ارسال…' : 'ارسال تیکت'),
          ),
        ],
      ),
    );
  }
}
