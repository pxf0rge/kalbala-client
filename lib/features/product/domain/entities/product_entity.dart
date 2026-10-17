/// Global catalog product (pricing/stock per booth in Phase 10 listings).
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.createdBy,
    this.description,
    this.categoryId,
    this.brand,
    this.weightGrams = 0,
    this.hasVariants = false,
    this.images = const [],
    this.isBlocked = false,
    this.approvalStatus = 'approved',
    this.rejectionReason,
  });

  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? brand;
  final int weightGrams;
  final bool hasVariants;
  final List<String> images;
  final String createdBy;
  final bool isBlocked;
  final String approvalStatus;
  final String? rejectionReason;

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  bool get isApproved => approvalStatus == 'approved';
  bool get isPendingApproval => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';

  String get approvalLabelFa => switch (approvalStatus) {
        'pending' => 'در انتظار تأیید',
        'approved' => 'تأیید شده',
        'rejected' => 'رد شده',
        _ => approvalStatus,
      };
}
