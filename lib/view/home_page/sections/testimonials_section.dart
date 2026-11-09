import 'package:flutter/material.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/hover_card/hover_card.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

/// Shows the testimonials listed in [SiteContent.testimonials]. Until genuine
/// client feedback is added there, it invites clients to share theirs.
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const items = SiteContent.testimonials;
    final cols = context.responsive(1, 2, 3);

    return SectionShell(
      background: AppColors.offWhite,
      backdrop: const ConstellationField(seed: 7, opacity: 0.9),
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'Testimonials',
            title: 'What Clients Say',
            subtitle: SiteContent.testimonialsIntro,
            centered: true,
          ),
          const SizedBox(height: 52),
          if (items.isEmpty)
            const Reveal(child: _ShareExperienceCard())
          else
            ResponsiveGrid(
              columns: cols,
              spacing: 22,
              centerLastRow: true,
              children: [
                for (var i = 0; i < items.length; i++)
                  Reveal(
                    delay: Duration(milliseconds: 100 * (i % cols)),
                    child: _TestimonialCard(items[i]),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard(this.t);
  final Testimonial t;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(30),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 40,
            color: hovered ? AppColors.warmAccent : AppColors.hairline,
          ),
          const SizedBox(height: 12),
          Text(
            t.quote,
            style: AppText.body(
              15.5,
              color: AppColors.charcoal,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 22),
          Text(t.name, style: AppText.heading(16)),
          if (t.detail != null)
            Text(
              t.detail!,
              style: AppText.body(13, color: AppColors.mediumGray),
            ),
        ],
      ),
    );
  }
}

class _ShareExperienceCard extends StatelessWidget {
  const _ShareExperienceCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          padding: EdgeInsets.all(context.isMobile ? 28 : 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.hairline),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 52,
                color: AppColors.warmAccent,
              ),
              const SizedBox(height: 14),
              Text(
                'Client experiences will be published here with their '
                'permission.',
                textAlign: TextAlign.center,
                style: AppText.heading(20),
              ),
              const SizedBox(height: 12),
              Text(
                'Have you consulted with us? We would be grateful to hear '
                'about your experience.',
                textAlign: TextAlign.center,
                style: AppText.body(15, color: AppColors.mediumGray),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Share Your Experience',
                faIcon: FontAwesomeIcons.whatsapp,
                variant: AppButtonVariant.outlineDark,
                compact: true,
                onPressed: () => ContactLauncher.openWhatsApp(
                  'Hello Guru Kripa Astro Science, I would like to share my '
                  'experience of my consultation:\n\n',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
