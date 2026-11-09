import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';

/// ✦ EYEBROW ✦ + title + celestial divider + optional subtitle.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.centered = false,
    this.dark = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool centered;

  /// True when shown on a dark background.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Reveal(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StarGlyph(size: 12),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: AppText.eyebrow(
                    color: dark ? AppColors.warmAccent : AppColors.slate,
                  ),
                ),
              ),
              if (centered) ...[
                const SizedBox(width: 12),
                const StarGlyph(size: 12),
              ],
            ],
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Text(
              title,
              textAlign: textAlign,
              style: AppText.heading(
                context.responsive(28.0, 36.0, 44.0),
                color: dark ? Colors.white : AppColors.charcoal,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CelestialDivider(
            color: AppColors.warmAccent.withValues(alpha: dark ? 0.9 : 0.8),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                subtitle!,
                textAlign: textAlign,
                style: AppText.body(
                  16,
                  color: dark
                      ? Colors.white.withValues(alpha: 0.68)
                      : AppColors.mediumGray,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A full-width page section with a background, an optional animated
/// [backdrop] (stars, constellations…) and vertical padding.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.background = AppColors.offWhite,
    this.decoration,
    this.backdrop,
  });

  final Widget child;
  final Color background;
  final Decoration? decoration;
  final Widget? backdrop;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: context.sectionPadding),
      child: ContentWidth(child: child),
    );
    return Container(
      decoration: decoration ?? BoxDecoration(color: background),
      child: backdrop == null
          ? content
          : Stack(
              children: [
                Positioned.fill(child: IgnorePointer(child: backdrop!)),
                content,
              ],
            ),
    );
  }
}

/// Body paragraph with the site's reading style.
class Paragraph extends StatelessWidget {
  const Paragraph(this.text, {super.key, this.dark = false, this.size = 16});

  final String text;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        text,
        style: AppText.body(
          size,
          color: dark ? Colors.white.withValues(alpha: 0.72) : AppColors.slate,
          height: 1.8,
        ),
      ),
    );
  }
}

/// Positions a decorative widget partly outside a section's edge.
class Watermark extends StatelessWidget {
  const Watermark({
    super.key,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final Widget child;
  final double? left, top, right, bottom;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.hardEdge,
    children: [
      Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: child,
      ),
    ],
  );
}
