import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/utils/image_compress_utils.dart';
import 'package:rahmani_project/core/utils/safe_image_picker.dart';
import 'package:rahmani_project/core/utils/slug_utils.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:rahmani_project/features/booth/domain/entities/afghanistan_provinces.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/booth_image_upload_tile.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/business_hours_editor.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/ownership_type_selector.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/verification_status_badge.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/profile/presentation/constants/afghanistan_cities.dart';

/// Apply for a new booth (permanent or rental) with full contact details.
class BoothApplicationScreen extends ConsumerStatefulWidget {
  const BoothApplicationScreen({super.key});

  @override
  ConsumerState<BoothApplicationScreen> createState() => _BoothApplicationScreenState();
}

class _BoothApplicationScreenState extends ConsumerState<BoothApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  OwnershipType _ownershipType = OwnershipType.permanent;
  String _selectedCity = AfghanistanCities.cities.first;
  String _selectedProvince = AfghanistanProvinces.all.first;
  String? _categoryId;
  BusinessHours _hours = BusinessHours.defaults();
  List<int>? _logoBytes;
  String _logoExt = 'jpg';
  List<int>? _coverBytes;
  String _coverExt = 'jpg';
  bool _isSubmitting = false;
  bool _isPickingImage = false;
  bool _pickingLogo = false;
  bool _isRefreshing = false;
  double? _uploadProgress;
  String _uploadMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing || _isSubmitting) return;
    setState(() => _isRefreshing = true);
    try {
      await Future.wait([
        ref.read(myApplicationsProvider.notifier).refresh(),
        ref.read(myBoothsProvider.notifier).refresh(),
      ]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وضعیت درخواست فروشگاه به‌روز شد')),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _onNameChanged(String value) {
    _slugController.text = SlugUtils.slugify(value);
  }

  Future<void> _pickImage({required bool isLogo}) async {
    if (_isPickingImage || _isSubmitting) return;
    setState(() {
      _isPickingImage = true;
      _pickingLogo = isLogo;
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
        _uploadProgress = 0.35;
        _uploadMessage = 'در حال فشرده‌سازی…';
      });
      final bytes =
          await ImageCompressUtils.compressForUpload(await file.readAsBytes());
      final ext = file.path.split('.').last.toLowerCase();
      if (!mounted) return;
      setState(() {
        if (isLogo) {
          _logoBytes = bytes;
          _logoExt = ext == 'jpeg' ? 'jpg' : ext;
        } else {
          _coverBytes = bytes;
          _coverExt = ext == 'jpeg' ? 'jpg' : ext;
        }
        _uploadProgress = 1;
        _uploadMessage = 'آماده';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
          _uploadProgress = null;
          _uploadMessage = '';
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0;
      _uploadMessage = 'شروع ارسال…';
    });
    final result = await ref.read(applyForBoothProvider).call(
          BoothApplicationInput(
            boothName: _nameController.text,
            slug: _slugController.text,
            ownershipType: _ownershipType,
            description: _descriptionController.text,
            categoryId: _categoryId,
            phone: _phoneController.text,
            address: _addressController.text,
            city: _selectedCity,
            province: _selectedProvince,
            businessHours: _hours,
            logoBytes: _logoBytes,
            logoExtension: _logoExt,
            coverBytes: _coverBytes,
            coverExtension: _coverExt,
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

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(myApplicationsProvider);
        ref.invalidate(myBoothsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('درخواست فروشگاه ارسال شد — منتظر تأیید ادمین باشید')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(childCategoriesProvider(null)).valueOrNull ?? [];
    final applications = ref.watch(myApplicationsProvider).valueOrNull ?? [];
    final hasPending = applications.any((a) => a.isPending);
    final latest = applications.isEmpty ? null : applications.first;
    final busy = _isSubmitting || _isPickingImage;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('درخواست فروشگاه'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              if (latest != null) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'آخرین درخواست: ${latest.boothName}',
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            VerificationStatusBadge(status: latest.status),
                          ],
                        ),
                        if (latest.isRejected &&
                            latest.rejectionReason != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'دلیل رد: ${latest.rejectionReason}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        if (latest.isPending) ...[
                          const SizedBox(height: 8),
                          Text(
                            'درخواست در حال بررسی است. با به‌روزرسانی وضعیت، نتیجه را ببینید.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        if (latest.status == ApprovalStatus.approved) ...[
                          const SizedBox(height: 8),
                          Text(
                            'این درخواست تأیید شده و فروشگاه شما ساخته شده است.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed:
                                busy || _isRefreshing ? null : _refreshStatus,
                            icon: const Icon(Icons.sync, size: 18),
                            label: const Text('به‌روزرسانی وضعیت'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (hasPending)
                Text(
                  'تا زمان بررسی درخواست فعلی، امکان ارسال درخواست جدید نیست.',
                  style: theme.textTheme.bodyMedium,
                )
              else ...[
                const Text(
                  'پس از تأیید ادمین، فروشگاه شما با همین اطلاعات ساخته می‌شود. برای فروشگاه اجاره‌ای، مدت اجاره توسط ادمین تعیین می‌شود.',
                ),
                const SizedBox(height: 24),
                OwnershipTypeSelector(
                  value: _ownershipType,
                  onChanged: (type) {
                    if (busy) return;
                    setState(() => _ownershipType = type);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'نام فروشگاه',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onNameChanged,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'الزامی' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slugController,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'نامک (انگلیسی)',
                    hintText: 'my-shop',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final slug = SlugUtils.slugify(v ?? '');
                    return SlugUtils.isValid(slug) ? null : 'نامک نامعتبر';
                  },
                ),
                const SizedBox(height: 16),
                if (categories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'دسته‌بندی',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('انتخاب نشده'),
                      ),
                      ...categories.map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged:
                        busy ? null : (v) => setState(() => _categoryId = v),
                  ),
                if (categories.isNotEmpty) const SizedBox(height: 16),
                PhoneInputField(controller: _phoneController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedProvince,
                  decoration: const InputDecoration(
                    labelText: 'ولایت',
                    border: OutlineInputBorder(),
                  ),
                  items: AfghanistanProvinces.all
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: busy
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() => _selectedProvince = v);
                          }
                        },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'شهر',
                    border: OutlineInputBorder(),
                  ),
                  items: AfghanistanCities.cities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: busy
                      ? null
                      : (v) {
                          if (v != null) setState(() => _selectedCity = v);
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'آدرس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !busy,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات (اختیاری)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                BusinessHoursEditor(
                  value: _hours,
                  onChanged:
                      busy ? (_) {} : (h) => setState(() => _hours = h),
                ),
                const SizedBox(height: 16),
                BoothImageUploadTile(
                  title: 'لوگو',
                  emptyLabel: 'انتخاب لوگو (اختیاری)',
                  icon: Icons.image_outlined,
                  bytes: _logoBytes,
                  enabled: !busy,
                  busy: _isPickingImage && _pickingLogo,
                  busyLabel: _uploadMessage,
                  progress: _isPickingImage && _pickingLogo
                      ? _uploadProgress
                      : null,
                  onPick: () => _pickImage(isLogo: true),
                ),
                const SizedBox(height: 8),
                BoothImageUploadTile(
                  title: 'کاور',
                  emptyLabel: 'انتخاب کاور (اختیاری)',
                  icon: Icons.photo_outlined,
                  bytes: _coverBytes,
                  enabled: !busy,
                  busy: _isPickingImage && !_pickingLogo,
                  busyLabel: _uploadMessage,
                  progress: _isPickingImage && !_pickingLogo
                      ? _uploadProgress
                      : null,
                  onPick: () => _pickImage(isLogo: false),
                ),
                if (_isSubmitting && _uploadProgress != null) ...[
                  const SizedBox(height: 16),
                  BoothSubmitProgressBar(
                    progress: _uploadProgress!,
                    message: _uploadMessage,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : _submit,
                  child: Text(
                    _isSubmitting ? 'در حال ارسال…' : 'ارسال درخواست',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
