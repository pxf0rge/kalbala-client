import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/utils/image_compress_utils.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/core/utils/safe_image_picker.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/verification_status_badge.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/shared/widgets/app_upload_progress_bar.dart';

/// Submit seller identity verification documents.
class SellerVerificationScreen extends ConsumerStatefulWidget {
  const SellerVerificationScreen({super.key});

  @override
  ConsumerState<SellerVerificationScreen> createState() =>
      _SellerVerificationScreenState();
}

class _SellerVerificationScreenState
    extends ConsumerState<SellerVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  List<int>? _photoBytes;
  String _photoExtension = 'jpg';
  bool _initialized = false;
  bool _isSubmitting = false;
  bool _isPicking = false;
  bool _isRefreshing = false;
  double? _uploadProgress;
  String _uploadMessage = '';

  void _initializeFromProfile() {
    if (_initialized) return;
    final profile = ref.read(profileProvider).valueOrNull;
    _nameController.text = profile?.fullName ?? '';
    if (profile?.phone != null &&
        profile!.phone.startsWith(PhoneUtils.countryCode)) {
      _phoneController.text =
          '0${profile.phone.substring(PhoneUtils.countryCode.length)}';
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing || _isSubmitting) return;
    setState(() => _isRefreshing = true);
    try {
      await ref.read(verificationProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وضعیت احراز هویت به‌روز شد')),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _pickPhoto() async {
    if (_isPicking || _isSubmitting) return;
    setState(() {
      _isPicking = true;
      _uploadProgress = null;
      _uploadMessage = 'در حال آماده‌سازی تصویر…';
    });
    try {
      final file = await SafeImagePicker.pickImage(
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() {
        _uploadProgress = 0.4;
        _uploadMessage = 'در حال فشرده‌سازی…';
      });
      final bytes =
          await ImageCompressUtils.compressForUpload(await file.readAsBytes());
      final ext = file.path.split('.').last.toLowerCase();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoExtension = ext == 'jpeg' ? 'jpg' : ext;
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
    if (!_formKey.currentState!.validate()) return;
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عکس تذکره الزامی است')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0;
      _uploadMessage = 'شروع ارسال…';
    });
    final success = await ref.read(verificationProvider.notifier).submit(
          VerificationInput(
            fullName: _nameController.text,
            idNumber: _idController.text,
            phone: _phoneController.text,
            photoBytes: _photoBytes!,
            photoExtension: _photoExtension,
          ),
          onProgress: (progress, message) {
            if (!mounted) return;
            setState(() {
              _uploadProgress = progress;
              _uploadMessage = message;
            });
          },
        );
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _uploadProgress = null;
      _uploadMessage = '';
    });

    if (success) {
      context.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خطا در ارسال درخواست احراز هویت')),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeFromProfile();
    final verificationAsync = ref.watch(verificationProvider);
    final verification = verificationAsync.valueOrNull;
    final canSubmit = verification == null || verification.isRejected;
    final busy = _isSubmitting || _isPicking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('احراز هویت فروشنده'),
        actions: [
          IconButton(
            tooltip: 'به‌روزرسانی وضعیت',
            onPressed: busy || _isRefreshing ? null : _refreshStatus,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            if (verification != null) ...[
              Row(
                children: [
                  VerificationStatusBadge(status: verification.status),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: busy || _isRefreshing ? null : _refreshStatus,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('به‌روزرسانی وضعیت'),
                  ),
                ],
              ),
              if (verification.isRejected &&
                  verification.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'دلیل رد: ${verification.rejectionReason}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
              if (verification.isPending) ...[
                const SizedBox(height: 12),
                Text(
                  'درخواست شما در حال بررسی است. پس از تصمیم ادمین، با دکمه به‌روزرسانی وضعیت را ببینید.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (verification.isApproved) ...[
                const SizedBox(height: 12),
                Text(
                  'احراز هویت شما تأیید شده است. می‌توانید درخواست فروشگاه ثبت کنید.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
            ],
            if (canSubmit)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      enabled: !busy,
                      decoration: const InputDecoration(
                        labelText: 'نام کامل (مطابق تذکره)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'الزامی' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idController,
                      enabled: !busy,
                      decoration: const InputDecoration(
                        labelText: 'شماره تذکره',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'الزامی' : null,
                    ),
                    const SizedBox(height: 16),
                    PhoneInputField(controller: _phoneController),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: busy ? null : _pickPhoto,
                      icon: _isPicking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        _photoBytes == null
                            ? 'انتخاب عکس تذکره'
                            : 'عکس انتخاب شد',
                      ),
                    ),
                    if ((_isPicking || _isSubmitting) &&
                        _uploadProgress != null) ...[
                      const SizedBox(height: 16),
                      AppUploadProgressBar(
                        progress: _uploadProgress!,
                        message: _uploadMessage,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      child: Text(
                        _isSubmitting ? 'در حال ارسال…' : 'ارسال برای بررسی',
                      ),
                    ),
                  ],
                ),
              )
            else if (verificationAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              const Text('درخواست شما در حال بررسی است یا تأیید شده.'),
          ],
        ),
      ),
    );
  }
}
