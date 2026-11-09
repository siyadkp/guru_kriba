import 'package:flutter/material.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/images/app_images.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class AstrologerSection extends StatelessWidget {
  const AstrologerSection({super.key, required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final portraitSize = context.responsive(260.0, 320.0, 380.0);

    final portrait = Reveal(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 1200),
      child: Column(
        children: [
          SizedBox.square(
            dimension: portraitSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotatingRing(size: portraitSize),
                _Portrait(size: portraitSize * 0.8),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            SiteContent.astrologerName,
            style: AppText.heading(20, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            SiteContent.astrologerRole.toUpperCase(),
            style: AppText.eyebrow(color: AppColors.warmAccent, size: 11),
          ),
        ],
      ),
    );

    final bio = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'About the Astrologer',
          title: 'Meet the Astrologer – ${SiteContent.astrologerName}',
          dark: true,
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < SiteContent.astrologerParagraphs.length; i++)
          Reveal(
            delay: Duration(milliseconds: 120 * i),
            child: Paragraph(SiteContent.astrologerParagraphs[i], dark: true),
          ),
        const SizedBox(height: 8),
        Reveal(
          delay: const Duration(milliseconds: 300),
          child: Text(
            'AREAS OF EXPERTISE',
            style: AppText.eyebrow(
              color: Colors.white.withValues(alpha: 0.5),
              size: 11.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Reveal(
          delay: const Duration(milliseconds: 380),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in SiteContent.astrologerExpertise) _Chip(e),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Reveal(
          delay: const Duration(milliseconds: 460),
          child: AppButton(
            label: 'Consult ${SiteContent.astrologerName}',
            icon: Icons.calendar_month_outlined,
            variant: AppButtonVariant.gold,
            onPressed: onBook,
          ),
        ),
      ],
    );

    return SectionShell(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF2B2F35),
            AppColors.charcoal,
            AppColors.charcoalDeep,
          ],
          stops: [0, 0.55, 1],
        ),
      ),
      backdrop: const Stack(
        children: [
          Positioned.fill(child: Nebula(intensity: 0.9)),
          Positioned.fill(child: Starfield(count: 60, seed: 3)),
        ],
      ),
      child: desktop
          ? Row(
              children: [
                Expanded(flex: 4, child: portrait),
                const SizedBox(width: 56),
                Expanded(flex: 6, child: bio),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [portrait, const SizedBox(height: 56), bio],
            ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    const photo = AppImages.astrologerPhoto;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.slate, AppColors.charcoalSoft],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmAccent.withValues(alpha: 0.18),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photo != null
          // Gray-scale imagery, as the design brief asks.
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0, //
                0.2126, 0.7152, 0.0722, 0, 0, //
                0.2126, 0.7152, 0.0722, 0, 0, //
                0, 0, 0, 1, 0,
              ]),
              child: Image.asset(
                photo,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            )
          : Text(
              'VS',
              style: AppText.heading(
                size * 0.28,
                color: Colors.white,
                weight: FontWeight.w300,
                letterSpacing: 6,
              ),
            ),
    );
  }
}

class _Chip extends StatefulWidget {
  const _Chip(this.label);
  final String label;

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: _hovered ? Colors.white : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Text(
          widget.label,
          style: AppText.body(
            13,
            color: _hovered ? AppColors.charcoal : Colors.white,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
