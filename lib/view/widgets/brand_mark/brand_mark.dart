import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';

/// Circular emblem: ring, twelve house dots and a four-point star.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 38, this.color = AppColors.charcoal});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BrandMarkPainter(color),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..color = color;
    canvas.drawCircle(c, r * 0.94, stroke);

    final dot = Paint()..color = color.withValues(alpha: 0.6);
    for (var i = 0; i < 12; i++) {
      final a = i * pi / 6;
      canvas.drawCircle(c + Offset(cos(a), sin(a)) * r * 0.74, r * 0.045, dot);
    }

    final star = Path();
    for (var i = 0; i < 8; i++) {
      final a = -pi / 2 + i * pi / 4;
      final rr = i.isEven ? r * 0.5 : r * 0.14;
      final p = c + Offset(cos(a), sin(a)) * rr;
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = AppColors.warmAccent);
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) => old.color != color;
}

/// Emblem + two-line wordmark.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.color = AppColors.charcoal, this.scale = 1});

  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: 38 * scale, color: color),
        SizedBox(width: 12 * scale),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GURU KRIPA',
              style: AppText.heading(
                16 * scale,
                color: color,
                weight: FontWeight.w700,
                letterSpacing: 2.6,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ASTRO SCIENCE',
              style: AppText.body(
                9.5 * scale,
                color: color.withValues(alpha: 0.7),
                weight: FontWeight.w600,
                letterSpacing: 4.2,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
