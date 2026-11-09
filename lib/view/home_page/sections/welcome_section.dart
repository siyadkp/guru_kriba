import 'package:flutter/material.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/view/widgets/marquee/marquee.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Welcome',
          title: SiteContent.welcomeTitle,
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < SiteContent.welcomeParagraphs.length; i++)
          Reveal(
            delay: Duration(milliseconds: 120 * i),
            child: Paragraph(SiteContent.welcomeParagraphs[i]),
          ),
      ],
    );

    final areas = Reveal(
      delay: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.platinum, Color(0xFFE4EAF1)],
          ),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Only the decoration is clipped: content inside a clip would
            // never report itself visible, so its reveal would not start.
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: const Watermark(
                  right: -110,
                  top: -110,
                  child: CosmicWheel(
                    size: 300,
                    color: AppColors.slate,
                    animate: false,
                    opacity: 0.14,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.isMobile ? 26 : 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AREAS WE HELP YOU EXPLORE',
                    style: AppText.eyebrow(color: AppColors.slate, size: 11.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where the stars can guide you',
                    style: AppText.heading(21),
                  ),
                  const SizedBox(height: 22),
                  for (var i = 0; i < SiteContent.areasWeHelp.length; i++)
                    Reveal(
                      delay: Duration(milliseconds: 250 + 80 * i),
                      offset: const Offset(0.05, 0),
                      child: _AreaRow(SiteContent.areasWeHelp[i]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionShell(
          background: Colors.white,
          backdrop: const ConstellationField(seed: 2, opacity: 0.8),
          child: desktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: intro),
                    const SizedBox(width: 64),
                    Expanded(flex: 5, child: areas),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [intro, const SizedBox(height: 20), areas],
                ),
        ),
        const _ZodiacBand(),
      ],
    );
  }
}

/// Dark band: core services and the twelve rashis scrolling in opposite
/// directions over a starfield.
class _ZodiacBand extends StatelessWidget {
  const _ZodiacBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.charcoalDeep,
      child: Stack(
        children: [
          const Positioned.fill(child: Starfield(count: 40, seed: 11)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Text(
                  'EXPLORE OUR CORE SERVICES',
                  style: AppText.eyebrow(
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Marquee(
                  items: SiteContent.coreServices,
                  style: AppText.heading(
                    context.isMobile ? 19 : 24,
                    color: Colors.white,
                    weight: FontWeight.w500,
                  ),
                  height: 62,
                  starSize: 14,
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.warmAccent.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Marquee(
                  items: rashiNames,
                  reverse: true,
                  speed: 32,
                  height: 44,
                  gap: 22,
                  starSize: 8,
                  style: AppText.body(
                    12.5,
                    color: AppColors.warmAccent.withValues(alpha: 0.8),
                    weight: FontWeight.w600,
                    letterSpacing: 4,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaRow extends StatelessWidget {
  const _AreaRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.charcoal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const StarGlyph(size: 11),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: AppText.body(15, color: AppColors.charcoal, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}
