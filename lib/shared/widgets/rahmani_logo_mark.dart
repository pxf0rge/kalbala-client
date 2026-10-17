import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';

/// KalBala mark — shopping cart decorated with a bold **K**.
class KalBalaLogoMark extends StatelessWidget {
  const KalBalaLogoMark({
    this.size = 36,
    this.color,
    this.showAccent = true,
    this.useBrandAsset = false,
    super.key,
  });

  final double size;
  final Color? color;
  final bool showAccent;

  /// When true, shows the full branded PNG (green tile with cart + K).
  final bool useBrandAsset;

  @override
  Widget build(BuildContext context) {
    if (useBrandAsset) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/branding/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    final paintColor = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.primary);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _KalBalaMarkPainter(
          color: paintColor,
          accent: showAccent ? AppColors.accent : paintColor,
        ),
      ),
    );
  }
}

/// Backward-compatible alias used across the app.
typedef RahmaniLogoMark = KalBalaLogoMark;

class _KalBalaMarkPainter extends CustomPainter {
  _KalBalaMarkPainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sw = w * 0.075;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final accentFill = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    // Cart basket (trapezoid)
    final basket = Path()
      ..moveTo(w * 0.18, h * 0.34)
      ..lineTo(w * 0.82, h * 0.34)
      ..lineTo(w * 0.74, h * 0.68)
      ..lineTo(w * 0.26, h * 0.68)
      ..close();
    canvas.drawPath(basket, stroke);

    // Basket grid lines
    canvas.drawLine(Offset(w * 0.34, h * 0.34), Offset(w * 0.38, h * 0.68), stroke);
    canvas.drawLine(Offset(w * 0.50, h * 0.34), Offset(w * 0.50, h * 0.68), stroke);
    canvas.drawLine(Offset(w * 0.66, h * 0.34), Offset(w * 0.62, h * 0.68), stroke);
    canvas.drawLine(Offset(w * 0.22, h * 0.50), Offset(w * 0.78, h * 0.50), stroke);

    // Handle
    final handle = Path()
      ..moveTo(w * 0.28, h * 0.34)
      ..quadraticBezierTo(w * 0.28, h * 0.16, w * 0.50, h * 0.16)
      ..quadraticBezierTo(w * 0.72, h * 0.16, w * 0.72, h * 0.34);
    canvas.drawPath(handle, stroke);

    // Wheels
    canvas.drawCircle(Offset(w * 0.34, h * 0.80), w * 0.07, fill);
    canvas.drawCircle(Offset(w * 0.66, h * 0.80), w * 0.07, fill);

    // Bold K badge on cart
    final badgeR = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.50),
      width: w * 0.36,
      height: w * 0.36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeR, Radius.circular(w * 0.08)),
      accentFill,
    );

    final kPainter = TextPainter(
      text: TextSpan(
        text: 'K',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.26,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    kPainter.paint(
      canvas,
      Offset(
        badgeR.center.dx - kPainter.width / 2,
        badgeR.center.dy - kPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _KalBalaMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.accent != accent;
}

/// Logo + wordmark lockup for splash / headers.
class KalBalaBrandLockup extends StatelessWidget {
  const KalBalaBrandLockup({
    this.logoSize = 64,
    this.nameSize = 32,
    this.color = Colors.white,
    this.showTagline = true,
    this.tagline,
    this.axis = Axis.vertical,
    super.key,
  });

  final double logoSize;
  final double nameSize;
  final Color color;
  final bool showTagline;
  final String? tagline;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final name = Text(
      'کال بالا',
      style: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: nameSize,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
        letterSpacing: -0.5,
      ),
    );
    final en = Text(
      'KalBala',
      style: TextStyle(
        fontSize: nameSize * 0.38,
        fontWeight: FontWeight.w600,
        color: color.withValues(alpha: 0.75),
        letterSpacing: 1.4,
        height: 1.2,
      ),
    );
    final logo = KalBalaLogoMark(
      size: logoSize,
      useBrandAsset: true,
    );

    if (axis == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          SizedBox(width: logoSize * 0.22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              name,
              en,
              if (showTagline) ...[
                const SizedBox(height: 4),
                Text(
                  tagline ?? 'بازار آنلاین فروشگاه‌های افغانستان',
                  style: TextStyle(
                    fontSize: nameSize * 0.32,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(height: logoSize * 0.28),
        name,
        const SizedBox(height: 4),
        en,
        if (showTagline) ...[
          SizedBox(height: logoSize * 0.16),
          Text(
            tagline ?? 'بازار آنلاین فروشگاه‌های افغانستان',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: math.max(13, nameSize * 0.38),
              color: color.withValues(alpha: 0.72),
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
