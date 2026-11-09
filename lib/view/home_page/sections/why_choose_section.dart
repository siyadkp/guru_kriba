import 'package:flutter/material.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/view/widgets/hover_card/hover_card.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(1, 2, 3);
    final items = SiteContent.whyChoose;
    const duration = Duration(milliseconds: 280);

    return SectionShell(
      background: Colors.white,
      backdrop: const ConstellationField(seed: 5, opacity: 0.8),
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'Why Choose Us',
            title: 'Why Choose Guru Kripa Astro Science?',
            centered: true,
          ),
          const SizedBox(height: 56),
          ResponsiveGrid(
            columns: cols,
            spacing: 22,
            centerLastRow: true,
            children: [
              for (var i = 0; i < items.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 100 * (i % cols)),
                  child: HoverCard(
                    color: AppColors.offWhite.withValues(alpha: 0.95),
                    hoverColor: AppColors.charcoal,
                    hoverBorderColor: AppColors.warmAccent.withValues(
                      alpha: 0.6,
                    ),
                    padding: EdgeInsets.zero,
                    builder: (context, hovered) => SizedBox(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    OrbitBadge(
                                      icon: items[i].icon,
                                      active: hovered,
                                      size: 48,
                                      activeFill: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    const Spacer(),
                                    AnimatedDefaultTextStyle(
                                      duration: duration,
                                      style: AppText.heading(
                                        40,
                                        weight: FontWeight.w700,
                                        height: 1,
                                        color: hovered
                                            ? AppColors.warmAccent.withValues(
                                                alpha: 0.35,
                                              )
                                            : AppColors.hairline,
                                      ),
                                      child: Text('0${i + 1}'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                AnimatedDefaultTextStyle(
                                  duration: duration,
                                  style: AppText.heading(
                                    19,
                                    color: hovered
                                        ? Colors.white
                                        : AppColors.charcoal,
                                  ),
                                  child: Text(items[i].title),
                                ),
                                const SizedBox(height: 10),
                                AnimatedDefaultTextStyle(
                                  duration: duration,
                                  style: AppText.body(
                                    15,
                                    color: hovered
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.mediumGray,
                                  ),
                                  child: Text(items[i].description),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
