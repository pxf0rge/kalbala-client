import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/features/profile/presentation/constants/afghanistan_city_coordinates.dart';

/// Compact map preview + fullscreen pin picker for delivery location.
class AddressLocationPicker extends StatelessWidget {
  const AddressLocationPicker({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.onChanged,
    super.key,
  });

  final String city;
  final double? latitude;
  final double? longitude;
  final void Function(double latitude, double longitude) onChanged;

  bool get _hasPin => latitude != null && longitude != null;

  LatLng get _center {
    if (_hasPin) return LatLng(latitude!, longitude!);
    return AfghanistanCityCoordinates.forCity(city);
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddressMapPickerScreen(
          initial: _hasPin ? LatLng(latitude!, longitude!) : null,
          city: city,
        ),
      ),
    );
    if (result != null) {
      onChanged(result.latitude, result.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('موقعیت روی نقشه', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'نقطه تحویل را روی نقشه مشخص کنید',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: 10),
        Material(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openPicker(context),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: _hasPin ? 15 : 12,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.rahmani.marketplace',
                        ),
                        if (_hasPin)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(latitude!, longitude!),
                                width: 44,
                                height: 44,
                                alignment: Alignment.topCenter,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primary,
                                  size: 44,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _hasPin
                                  ? Icons.edit_location_alt_outlined
                                  : Icons.add_location_alt_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hasPin
                                    ? 'تغییر نقطه انتخاب‌شده'
                                    : 'انتخاب نقطه روی نقشه',
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                            const Icon(Icons.chevron_left_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_hasPin) ...[
          const SizedBox(height: 6),
          Text(
            '${latitude!.toStringAsFixed(5)} ، ${longitude!.toStringAsFixed(5)}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Fullscreen map where the user taps (or uses GPS) to place a pin.
class AddressMapPickerScreen extends StatefulWidget {
  const AddressMapPickerScreen({
    required this.city,
    this.initial,
    super.key,
  });

  final String city;
  final LatLng? initial;

  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  late final MapController _mapController;
  late LatLng _pin;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pin = widget.initial ?? AfghanistanCityCoordinates.forCity(widget.city);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('موقعیت‌یاب دستگاه خاموش است.')),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسترسی به موقعیت مکانی داده نشده است.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _pin = point);
      _mapController.move(point, 16);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دریافت موقعیت فعلی ناموفق بود.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب موقعیت'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _pin),
            child: const Text('تأیید'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pin,
              initialZoom: widget.initial != null ? 15 : 13,
              onTap: (_, point) => setState(() => _pin = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rahmani.marketplace',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pin,
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              color: Theme.of(context).colorScheme.surface,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  'روی نقشه بزنید تا سنجاق جابه‌جا شود',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'my-location',
                  tooltip: 'موقعیت فعلی من',
                  onPressed: _locating ? null : _useMyLocation,
                  child: _locating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'confirm-pin',
                  onPressed: () => Navigator.pop(context, _pin),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('تأیید موقعیت'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
