/// Delivery address owned by a user.
class AddressEntity {
  const AddressEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.street,
    this.district,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String userId;
  final String label;
  final String recipientName;
  final String phone;
  final String city;
  final String? district;
  final String street;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get fullAddress {
    final parts = <String>[
      city,
      if (district != null && district!.isNotEmpty) district!,
      street,
      if (postalCode != null && postalCode!.isNotEmpty) 'کد پستی: $postalCode',
    ];
    return parts.join('، ');
  }
}
