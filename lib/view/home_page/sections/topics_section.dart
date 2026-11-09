import 'dart:math';

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

/// Night-sky section: consultation topics beside the Navagraha orbit.
class TopicsSection extends StatelessWidget {
  const TopicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final topics = SiteContent.consultationTopics;
    final orbitSize = desktop
        ? 420.0
        : min(context.screenWidth - context.gutter * 2, 380.0);

    final header = const SectionHeader(
      eyebrow: 'Consultation Topics',
      title: 'What You Can Ask About',
      subtitle:
          'Clients can inquire about consultations or remedies related to:',
      dark: true,
    );

    final orbit = Reveal(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 1400),
      child: Column(
        children: [
          NavagrahaOrbit(size: orbitSize),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StarGlyph(size: 9),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'NAVAGRAHA · THE NINE CELESTIAL INFLUENCES',
                  textAlign: TextAlign.center,
                  style: AppText.eyebrow(
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final grid = ResponsiveGrid(
      columns: context.responsive(1, 2, 2),
      spacing: 16,
      children: [
        for (var i = 0; i < topics.length; i++)
          Reveal(
            delay: Duration(milliseconds: 70 * i),
            child: HoverCard(
              color: Colors.white.withValues(alpha: 0.04),
              hoverColor: Colors.white.withValues(alpha: 0.08),
              borderColor: Colors.white.withValues(alpha: 0.09),
              hoverBorderColor: AppColors.warmAccent.withValues(alpha: 0.6),
              padding: const EdgeInsets.all(18),
              radius: 18,
              builder: (context, hovered) => Row(
                children: [
                  OrbitBadge(
                    icon: topics[i].icon,
                    active: hovered,
                    dark: true,
                    size: 38,
                    activeFill: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      topics[i].text,
                      style: AppText.body(
                        14.5,
                        color: Colors.white.withValues(alpha: 0.86),
                        weight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return SectionShell(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.charcoalDeep, AppColors.charcoal],
        ),
      ),
      backdrop: const Stack(
        children: [
          Positioned.fill(child: Nebula(intensity: 0.8)),
          Positioned.fill(child: Starfield(count: 70, seed: 13)),
        ],
      ),
      child: desktop
          ? Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [header, const SizedBox(height: 28), orbit],
                  ),
                ),
                const SizedBox(width: 56),
                Expanded(flex: 7, child: grid),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 28),
                Center(child: orbit),
                const SizedBox(height: 36),
                grid,
              ],
            ),
    );
  }
}
