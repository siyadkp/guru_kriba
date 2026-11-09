import 'package:flutter/material.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;

    final about = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(eyebrow: 'About Us', title: SiteContent.aboutTitle),
        const SizedBox(height: 28),
        for (var i = 0; i < SiteContent.aboutParagraphs.length; i++)
          Reveal(
            delay: Duration(milliseconds: 120 * i),
            child: Paragraph(SiteContent.aboutParagraphs[i]),
          ),
      ],
    );

    final steps = SiteContent.methodology;
    final methodology = Reveal(
      delay: const Duration(milliseconds: 150),
      child: Container(
        padding: EdgeInsets.all(context.isMobile ? 24 : 40),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.hairline),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const StarGlyph(size: 11),
                const SizedBox(width: 10),
                Text(
                  'OUR APPROACH',
                  style: AppText.eyebrow(
                    color: AppColors.mediumGray,
                    size: 11.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Our Five-Step Methodology', style: AppText.heading(24)),
            const SizedBox(height: 30),
            for (var i = 0; i < steps.length; i++)
              Reveal(
                delay: Duration(milliseconds: 250 + 140 * i),
                offset: const Offset(0.05, 0),
                child: _TimelineStep(
                  number: i + 1,
                  item: steps[i],
                  last: i == steps.length - 1,
                ),
              ),
          ],
        ),
      ),
    );

    return SectionShell(
      background: AppColors.offWhite,
      backdrop: Stack(
        children: [
          const Positioned.fill(
            child: ConstellationField(seed: 4, clusters: 4, opacity: 0.6),
          ),
          Positioned.fill(
            child: Watermark(
              left: desktop ? -260 : -200,
              top: -120,
              child: CosmicWheel(
                size: desktop ? 720 : 480,
                color: AppColors.slate,
                animate: false,
                opacity: 0.09,
              ),
            ),
          ),
        ],
      ),
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: about),
                const SizedBox(width: 64),
                Expanded(flex: 6, child: methodology),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [about, const SizedBox(height: 20), methodology],
            ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.number,
    required this.item,
    required this.last,
  });

  final int number;
  final InfoItem item;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              children: [
                // A numbered "planet" inside its orbit.
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warmAccent.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.slate, AppColors.charcoal],
                      ),
                    ),
                    child: Text(
                      '$number',
                      style: AppText.heading(16, color: Colors.white),
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.warmAccent.withValues(alpha: 0.6),
                            AppColors.hairline,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: last ? 0 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.icon, size: 18, color: AppColors.warmAccent),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(item.title, style: AppText.heading(17)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: AppText.body(14.5, color: AppColors.mediumGray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
