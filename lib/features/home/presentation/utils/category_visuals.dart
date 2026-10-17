import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';

/// Resolves a marketplace icon + soft tint from category name/slug.
abstract final class CategoryVisuals {
  static CategoryLook resolve({String? name, String? slug, String? iconUrl}) {
    if (iconUrl != null && iconUrl.trim().isNotEmpty) {
      return CategoryLook.network(iconUrl.trim());
    }

    final key = '${name ?? ''} ${slug ?? ''}'.toLowerCase().trim();

    for (final entry in _rules) {
      if (entry.matches(key)) {
        return CategoryLook.icon(
          entry.icon,
          background: entry.background,
          foreground: entry.foreground,
        );
      }
    }

    return CategoryLook.icon(
      Icons.grid_view_rounded,
      background: AppColors.primarySoft,
      foreground: AppColors.primary,
    );
  }
}

class CategoryLook {
  const CategoryLook.icon(
    this.icon, {
    required this.background,
    required this.foreground,
  }) : networkUrl = null;

  CategoryLook.network(this.networkUrl)
      : icon = null,
        background = AppColors.canvas,
        foreground = AppColors.primary;

  final IconData? icon;
  final String? networkUrl;
  final Color background;
  final Color foreground;

  bool get isNetwork => networkUrl != null && networkUrl!.isNotEmpty;
}

class _Rule {
  const _Rule({
    required this.keywords,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final List<String> keywords;
  final IconData icon;
  final Color background;
  final Color foreground;

  bool matches(String key) => keywords.any(key.contains);
}

const _rules = <_Rule>[
  _Rule(
    keywords: ['موبایل', 'گوشی', 'تلفن', 'mobile', 'phone', 'smartphone'],
    icon: Icons.smartphone_rounded,
    background: Color(0xFFE8F1FF),
    foreground: Color(0xFF2563EB),
  ),
  _Rule(
    keywords: ['لپتاپ', 'لپ‌تاپ', 'کامپیوتر', 'رایانه', 'laptop', 'computer', 'pc'],
    icon: Icons.laptop_mac_rounded,
    background: Color(0xFFEEF2FF),
    foreground: Color(0xFF4F46E5),
  ),
  _Rule(
    keywords: ['تبلت', 'tablet', 'ipad'],
    icon: Icons.tablet_mac_rounded,
    background: Color(0xFFF0F9FF),
    foreground: Color(0xFF0284C7),
  ),
  _Rule(
    keywords: ['هدفون', 'هندزفری', 'هدفون', 'audio', 'headphone', 'earbud'],
    icon: Icons.headphones_rounded,
    background: Color(0xFFF5F3FF),
    foreground: Color(0xFF7C3AED),
  ),
  _Rule(
    keywords: ['الکترونیک', 'دیجیتال', 'گجت', 'electronic', 'digital', 'gadget'],
    icon: Icons.tv_rounded,
    background: Color(0xFFE0F2FE),
    foreground: Color(0xFF0369A1),
  ),
  _Rule(
    keywords: ['پوشاک', 'لباس', 'مد', 'fashion', 'clothing', 'apparel', 'لباس'],
    icon: Icons.checkroom_rounded,
    background: Color(0xFFFFF1F2),
    foreground: Color(0xFFE11D48),
  ),
  _Rule(
    keywords: ['کفش', 'صندل', 'کفش', 'shoe', 'sneaker', 'boot'],
    icon: Icons.ice_skating_outlined,
    background: Color(0xFFFFF7ED),
    foreground: Color(0xFFEA580C),
  ),
  _Rule(
    keywords: ['کیف', 'کوله', 'bag', 'backpack', 'wallet', 'کیف'],
    icon: Icons.shopping_bag_rounded,
    background: Color(0xFFFFFBEB),
    foreground: Color(0xFFD97706),
  ),
  _Rule(
    keywords: ['آرایشی', 'بهداشتی', 'زیبایی', 'میکاپ', 'cosmetic', 'beauty', 'makeup', 'skincare'],
    icon: Icons.spa_rounded,
    background: Color(0xFFFDF2F8),
    foreground: Color(0xFFDB2777),
  ),
  _Rule(
    keywords: ['خانه', 'خانگی', 'آشپزخانه', 'home', 'kitchen', 'household', 'لوازم خانگی'],
    icon: Icons.home_rounded,
    background: Color(0xFFECFDF5),
    foreground: Color(0xFF059669),
  ),
  _Rule(
    keywords: ['مبل', 'مبلمان', 'دکوراسیون', 'furniture', 'sofa', 'decor'],
    icon: Icons.weekend_rounded,
    background: Color(0xFFF0FDF4),
    foreground: Color(0xFF16A34A),
  ),
  _Rule(
    keywords: ['خوراکی', 'غذا', 'مواد غذایی', 'سوپر', 'food', 'grocery', 'supermarket'],
    icon: Icons.restaurant_rounded,
    background: Color(0xFFFFF7ED),
    foreground: Color(0xFFC2410C),
  ),
  _Rule(
    keywords: ['خودرو', 'ماشین', 'موتور', 'یدکی', 'car', 'auto', 'vehicle', 'motor'],
    icon: Icons.directions_car_filled_rounded,
    background: Color(0xFFEFF6FF),
    foreground: Color(0xFF1D4ED8),
  ),
  _Rule(
    keywords: ['ورزش', 'فیتنس', 'sport', 'fitness', 'gym'],
    icon: Icons.sports_soccer_rounded,
    background: Color(0xFFECFEFF),
    foreground: Color(0xFF0891B2),
  ),
  _Rule(
    keywords: ['کتاب', 'لوازم تحریر', 'book', 'stationery', 'مطالعه'],
    icon: Icons.menu_book_rounded,
    background: Color(0xFFFFFBEB),
    foreground: Color(0xFFB45309),
  ),
  _Rule(
    keywords: ['کودک', 'نوزاد', 'اسباب', 'baby', 'kids', 'toy', 'کودکان'],
    icon: Icons.child_care_rounded,
    background: Color(0xFFFDF4FF),
    foreground: Color(0xFFC026D3),
  ),
  _Rule(
    keywords: ['طلا', 'جواهر', 'ساعت', 'gold', 'jewelry', 'watch', 'ساعت'],
    icon: Icons.diamond_rounded,
    background: Color(0xFFFFFBEB),
    foreground: Color(0xFFCA8A04),
  ),
  _Rule(
    keywords: ['ابزار', 'صنعتی', 'ساختمان', 'tool', 'hardware', 'ساخت'],
    icon: Icons.handyman_rounded,
    background: Color(0xFFF8FAFC),
    foreground: Color(0xFF475569),
  ),
  _Rule(
    keywords: ['حیوان', 'پت', 'pet', 'animal'],
    icon: Icons.pets_rounded,
    background: Color(0xFFFFF1F2),
    foreground: Color(0xFFBE123C),
  ),
  _Rule(
    keywords: ['کشاورزی', 'باغ', 'گل', 'farm', 'garden', 'plant'],
    icon: Icons.local_florist_rounded,
    background: Color(0xFFF0FDF4),
    foreground: Color(0xFF15803D),
  ),
  _Rule(
    keywords: ['سلامت', 'دارو', 'پزشکی', 'health', 'medicine', 'pharmacy'],
    icon: Icons.medical_services_rounded,
    background: Color(0xFFECFEFF),
    foreground: Color(0xFF0E7490),
  ),
  _Rule(
    keywords: ['سفر', 'چمدان', 'travel', 'luggage', 'tourism'],
    icon: Icons.flight_takeoff_rounded,
    background: Color(0xFFEFF6FF),
    foreground: Color(0xFF2563EB),
  ),
  _Rule(
    keywords: ['بازی', 'کنسول', 'game', 'gaming', 'console'],
    icon: Icons.sports_esports_rounded,
    background: Color(0xFFF5F3FF),
    foreground: Color(0xFF6D28D9),
  ),
  _Rule(
    keywords: ['دوربین', 'عکاسی', 'camera', 'photo'],
    icon: Icons.photo_camera_rounded,
    background: Color(0xFFF1F5F9),
    foreground: Color(0xFF334155),
  ),
];
