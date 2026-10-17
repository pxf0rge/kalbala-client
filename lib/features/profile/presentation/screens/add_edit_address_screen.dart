import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/domain/repositories/profile_repository.dart';
import 'package:rahmani_project/features/profile/presentation/constants/afghanistan_cities.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/features/profile/presentation/widgets/address_location_picker.dart';

/// Create or edit a delivery address.
class AddEditAddressScreen extends ConsumerStatefulWidget {
  const AddEditAddressScreen({this.address, super.key});

  final AddressEntity? address;

  bool get isEditing => address != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _recipientController;
  late final TextEditingController _phoneController;
  late final TextEditingController _districtController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalCodeController;
  late String _selectedCity;
  double? _latitude;
  double? _longitude;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label ?? '');
    _recipientController = TextEditingController(text: address?.recipientName ?? '');
    _phoneController = TextEditingController(
      text: address != null
          ? '0${address.phone.substring(PhoneUtils.countryCode.length)}'
          : '',
    );
    _districtController = TextEditingController(text: address?.district ?? '');
    _streetController = TextEditingController(text: address?.street ?? '');
    _postalCodeController = TextEditingController(text: address?.postalCode ?? '');
    _selectedCity = address?.city ?? AfghanistanCities.cities.first;
    _latitude = address?.latitude;
    _longitude = address?.longitude;
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  AddressInput _buildInput() {
    final district = _districtController.text.trim();
    final postal = _postalCodeController.text.trim();
    return AddressInput(
      label: _labelController.text,
      recipientName: _recipientController.text,
      phone: _phoneController.text,
      city: _selectedCity,
      district: district.isEmpty ? null : district,
      street: _streetController.text,
      postalCode: postal.isEmpty ? null : postal,
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );
  }

  Future<void> _pickCity() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'انتخاب شهر',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final city in AfghanistanCities.cities)
                ListTile(
                  title: Text(city),
                  trailing: city == _selectedCity
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, city),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _selectedCity = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً نقطه تحویل را روی نقشه مشخص کنید.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final notifier = ref.read(addressesProvider.notifier);
    final error = widget.isEditing
        ? await notifier.updateAddress(widget.address!.id, _buildInput())
        : await notifier.add(_buildInput());

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'ویرایش آدرس' : 'آدرس جدید'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'عنوان آدرس (مثلاً خانه، محل کار)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'عنوان را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'نام گیرنده',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'نام گیرنده را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            PhoneInputField(controller: _phoneController),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'شهر',
                border: OutlineInputBorder(),
              ),
              child: InkWell(
                onTap: _pickCity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(_selectedCity)),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'ناحیه / منطقه (اختیاری)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'آدرس کامل',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'آدرس را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'کد پستی (اختیاری)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            AddressLocationPicker(
              city: _selectedCity,
              latitude: _latitude,
              longitude: _longitude,
              onChanged: (lat, lng) {
                setState(() {
                  _latitude = lat;
                  _longitude = lng;
                });
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('آدرس پیش‌فرض'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'به‌روزرسانی' : 'ذخیره آدرس'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
