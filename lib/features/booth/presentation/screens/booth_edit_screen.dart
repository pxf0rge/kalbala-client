import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/utils/image_compress_utils.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/core/utils/safe_image_picker.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:rahmani_project/features/booth/domain/entities/afghanistan_provinces.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';
import 'package:rahmani_project/features/booth/domain/entities/business_hours.dart';
import 'package:rahmani_project/features/booth/domain/repositories/booth_repository.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/booth_image_upload_tile.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/business_hours_editor.dart';
import 'package:rahmani_project/features/home/presentation/providers/home_provider.dart';
import 'package:rahmani_project/features/profile/presentation/constants/afghanistan_cities.dart';

/// Edit booth profile (seller owner) including hours and active toggle.
class BoothEditScreen extends ConsumerStatefulWidget {
  const BoothEditScreen({required this.boothId, super.key});

  final String boothId;

  @override
  ConsumerState<BoothEditScreen> createState() => _BoothEditScreenState();
}

class _BoothEditScreenState extends ConsumerState<BoothEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCity = AfghanistanCities.cities.first;
  String _selectedProvince = AfghanistanProvinces.all.first;
  String? _categoryId;
  BusinessHours _hours = BusinessHours.defaults();
  bool _isActive = false;
  List<int>? _logoBytes;
  String _logoExt = 'jpg';
  List<int>? _coverBytes;
  String _coverExt = 'jpg';
  bool _initialized = false;
  bool _isSaving = false;
  bool _togglingActive = false;
  bool _showPhone = true;
  bool _isPickingImage = false;
  bool _pickingLogo = false;
  double? _uploadProgress;
  String _uploadMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeFromBooth() {
    if (_initialized) return;
    final booth = ref.read(boothDetailProvider(widget.boothId)).valueOrNull;
    if (booth == null) return;
    _nameController.text = booth.name;
    _descriptionController.text = booth.description ?? '';
    _addressController.text = booth.address ?? '';
    _selectedCity = booth.city ?? AfghanistanCities.cities.first;
    _selectedProvince = booth.province ?? AfghanistanProvinces.all.first;
    _categoryId = booth.categoryId;
    _hours = booth.businessHours.days.isEmpty
        ? BusinessHours.defaults()
        : booth.businessHours;
    _isActive = booth.isActive;
    _showPhone = booth.showPhone;
    if (booth.phone != null && booth.phone!.startsWith(PhoneUtils.countryCode)) {
      _phoneController.text = '0${booth.phone!.substring(PhoneUtils.countryCode.length)}';
    }
    _initialized = true;
  }

  Future<void> _pickImage({required bool isLogo}) async {
    if (_isPickingImage || _isSaving) return;
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

  Future<void> _toggleActive(bool value) async {
    setState(() => _togglingActive = true);
    final ok = await ref.read(boothDetailProvider(widget.boothId).notifier).setActive(value);
    if (!mounted) return;
    setState(() {
      _togglingActive = false;
      if (ok) _isActive = value;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تغییر وضعیت فعال‌سازی ناموفق بود')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _uploadProgress = 0;
      _uploadMessage = 'شروع ذخیره…';
    });
    final success = await ref.read(boothDetailProvider(widget.boothId).notifier).updateBooth(
          BoothUpdateInput(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            phone: _phoneController.text,
            address: _addressController.text.trim(),
            city: _selectedCity,
            province: _selectedProvince,
            categoryId: _categoryId,
            businessHours: _hours,
            showPhone: _showPhone,
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
      _isSaving = false;
      _uploadProgress = null;
      _uploadMessage = '';
    });

    if (success) {
      context.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خطا در ذخیره فروشگاه')),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeFromBooth();
    final categories = ref.watch(childCategoriesProvider(null)).valueOrNull ?? [];
    final booth = ref.watch(boothDetailProvider(widget.boothId)).valueOrNull;
    final busy = _isSaving || _isPickingImage;

    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش فروشگاه')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (booth != null && booth.approvalStatus == ApprovalStatus.approved) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('فروشگاه فعال'),
                subtitle: Text(
                  _isActive
                      ? 'فروشگاه در بازار عمومی نمایش داده می‌شود'
                      : 'فروشگاه از نمایش عمومی خارج است',
                ),
                value: _isActive,
                onChanged: (_togglingActive || busy) ? null : _toggleActive,
              ),
              const Divider(),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: _nameController,
              enabled: !busy,
              decoration: const InputDecoration(labelText: 'نام فروشگاه', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'الزامی' : null,
            ),
            const SizedBox(height: 16),
            PhoneInputField(controller: _phoneController),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('نمایش تلفن در صفحه عمومی'),
              subtitle: const Text('خریدار بتواند با فروشگاه تماس بگیرد'),
              value: _showPhone,
              onChanged: busy ? null : (v) => setState(() => _showPhone = v),
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
                  const DropdownMenuItem(value: null, child: Text('انتخاب نشده')),
                  ...categories.map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ),
                ],
                onChanged: busy ? null : (v) => setState(() => _categoryId = v),
              ),
            if (categories.isNotEmpty) const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: AfghanistanProvinces.all.contains(_selectedProvince)
                  ? _selectedProvince
                  : AfghanistanProvinces.all.first,
              decoration: const InputDecoration(labelText: 'ولایت', border: OutlineInputBorder()),
              items: AfghanistanProvinces.all
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: busy
                  ? null
                  : (v) {
                      if (v != null) setState(() => _selectedProvince = v);
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: AfghanistanCities.cities.contains(_selectedCity)
                  ? _selectedCity
                  : AfghanistanCities.cities.first,
              decoration: const InputDecoration(labelText: 'شهر', border: OutlineInputBorder()),
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
              decoration: const InputDecoration(labelText: 'آدرس', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: !busy,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'توضیحات', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            BusinessHoursEditor(
              value: _hours,
              onChanged: busy ? (_) {} : (h) => setState(() => _hours = h),
            ),
            const SizedBox(height: 16),
            BoothImageUploadTile(
              title: 'لوگو',
              emptyLabel: 'انتخاب لوگو',
              icon: Icons.image_outlined,
              bytes: _logoBytes,
              enabled: !busy,
              busy: _isPickingImage && _pickingLogo,
              busyLabel: _uploadMessage,
              progress: _isPickingImage && _pickingLogo ? _uploadProgress : null,
              onPick: () => _pickImage(isLogo: true),
            ),
            const SizedBox(height: 8),
            BoothImageUploadTile(
              title: 'کاور',
              emptyLabel: 'انتخاب تصویر کاور',
              icon: Icons.photo_outlined,
              bytes: _coverBytes,
              enabled: !busy,
              busy: _isPickingImage && !_pickingLogo,
              busyLabel: _uploadMessage,
              progress: _isPickingImage && !_pickingLogo ? _uploadProgress : null,
              onPick: () => _pickImage(isLogo: false),
            ),
            if (_isSaving && _uploadProgress != null) ...[
              const SizedBox(height: 16),
              BoothSubmitProgressBar(
                progress: _uploadProgress!,
                message: _uploadMessage,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : _save,
              child: Text(_isSaving ? 'در حال ذخیره…' : 'ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
