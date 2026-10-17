import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/theme/app_text_styles.dart';

/// Visual weight for marketplace section headers.
enum RahmaniSectionEmphasis { high, normal, low }

/// Soft section header with optional action and emphasis hierarchy.
class RahmaniSectionHeader extends StatelessWidget {
  const RahmaniSectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.emphasis = RahmaniSectionEmphasis.normal,
    this.padding,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final RahmaniSectionEmphasis emphasis;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHigh = emphasis == RahmaniSectionEmphasis.high;
    final isLow = emphasis == RahmaniSectionEmphasis.low;

    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(
          AppSpacing.screen,
          isHigh ? AppSpacing.xl : (isLow ? AppSpacing.md : AppSpacing.lg),
          AppSpacing.screen,
          isHigh ? AppSpacing.md : AppSpacing.sm,
        );

    final titleStyle = isHigh
        ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.2)
        : isLow
            ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.25)
            : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.25);

    return Padding(
      padding: resolvedPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isHigh) ...[
            Container(
              width: 4,
              height: 22,
              margin: const EdgeInsetsDirectional.only(end: 8, bottom: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.chevron_left, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Marketplace search field (sticky-friendly white bar).
class RahmaniSearchBar extends StatelessWidget {
  const RahmaniSearchBar({
    this.hint = 'جستجوی محصول، فروشگاه یا دسته…',
    this.onTap,
    this.readOnly = true,
    this.controller,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final String hint;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: readOnly ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A212121),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            color: AppColors.surfaceRaised,
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search_rounded, color: AppColors.inkMuted, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: readOnly
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          hint,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.inkMuted,
                              ),
                        ),
                      )
                    : TextField(
                        controller: controller,
                        autofocus: autofocus,
                        textInputAction: TextInputAction.search,
                        onSubmitted: onSubmitted,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact price label with currency symbol — bold ink (marketplace pattern).
class RahmaniPriceText extends StatelessWidget {
  const RahmaniPriceText({
    required this.formatted,
    this.symbol,
    this.style,
    this.accent = false,
    super.key,
  });

  final String formatted;
  final String? symbol;
  final TextStyle? style;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final base = style ??
        AppTextStyles.price.copyWith(
          color: accent ? AppColors.primary : AppColors.ink,
        );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: formatted, style: base),
          if (symbol != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: symbol,
              style: base.copyWith(fontSize: (base.fontSize ?? 15) * 0.9),
            ),
          ],
        ],
      ),
    );
  }
}

/// Soft status chip.
class RahmaniChip extends StatelessWidget {
  const RahmaniChip({
    required this.label,
    this.tone = RahmaniChipTone.neutral,
    super.key,
  });

  final String label;
  final RahmaniChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      RahmaniChipTone.neutral => (AppColors.secondarySoft, AppColors.inkMuted),
      RahmaniChipTone.brand => (AppColors.primarySoft, AppColors.primary),
      RahmaniChipTone.accent => (AppColors.secondarySoft, AppColors.secondary),
      RahmaniChipTone.danger => (AppColors.errorSoft, AppColors.error),
      RahmaniChipTone.success => (const Color(0xFFD1FADF), AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

enum RahmaniChipTone { neutral, brand, accent, danger, success }

/// Network image with soft placeholder.
class RahmaniNetworkImage extends StatelessWidget {
  const RahmaniNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusSm);
    Widget child;
    if (url == null || url!.isEmpty) {
      child = Container(
        width: width,
        height: height,
        color: AppColors.secondarySoft,
        child: Icon(Icons.image_outlined, color: AppColors.inkMuted),
      );
    } else {
      child = Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: AppColors.secondarySoft,
          child: Icon(Icons.broken_image_outlined, color: AppColors.inkMuted),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.secondarySoft,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return ClipRRect(borderRadius: radius, child: child);
  }
}
