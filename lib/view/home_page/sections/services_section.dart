import 'package:flutter/material.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/view/widgets/hover_card/hover_card.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key, required this.onBookService});

  /// Called with the booking-form service label.
  final ValueChanged<String> onBookService;

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(1, 2, 4);
    final services = SiteContent.services;

    return SectionShell(
      background: AppColors.offWhite,
      backdrop: const ConstellationField(seed: 3, clusters: 7),
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'Our Services',
            title: 'Astrology, Spiritual Poojas & Energy Cleansing',
            subtitle:
                'Personalized consultations combining the analytical precision '
                'of KP Astrology with the traditional wisdom of Advanced Vedic '
                'Astrology — complemented by traditional spiritual remedies.',
            centered: true,
          ),
          const SizedBox(height: 56),
          ResponsiveGrid(
            columns: cols,
            spacing: 22,
            children: [
              for (var i = 0; i < services.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 90 * (i % cols)),
                  child: _ServiceCard(
                    item: services[i],
                    onBook: () => onBookService(services[i].bookingLabel!),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Reveal(child: _PoojaPanel(onBookService: onBookService)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.onBook});

  final InfoItem item;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      color: Colors.white.withValues(alpha: 0.94),
      hoverBorderColor: AppColors.warmAccent.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(24),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrbitBadge(icon: item.icon, active: hovered, size: 50),
          const SizedBox(height: 18),
          Text(item.title, style: AppText.heading(17.5)),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: AppText.body(
              14.5,
              color: AppColors.mediumGray,
              height: 1.65,
            ),
          ),
          if (item.note != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 15,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.note!,
                      style: AppText.body(
                        12.5,
                        color: AppColors.slate,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          const SizedBox(height: 18),
          ArrowLink(label: 'Book this service', onTap: onBook),
        ],
      ),
    );
  }
}

/// Dark featured panel for Spiritual Poojas & Negative Energy Extraction,
/// with its own starry sky and a slowly turning yantra.
class _PoojaPanel extends StatelessWidget {
  const _PoojaPanel({required this.onBookService});
  final ValueChanged<String> onBookService;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final items = SiteContent.poojaServices;

    final content = Padding(
      padding: EdgeInsets.all(mobile ? 24 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warmAccent.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppColors.warmAccent.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warmAccent.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.warmAccent,
                  size: 28,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StarGlyph(size: 11),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'SPIRITUAL REMEDIES',
                      style: AppText.eyebrow(color: AppColors.warmAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              SiteContent.poojaTitle,
              style: AppText.heading(
                context.responsive(24.0, 30.0, 36.0),
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CelestialDivider(),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              SiteContent.poojaDescription,
              style: AppText.body(
                16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 34),
          ResponsiveGrid(
            columns: context.responsive(1, 1, 3),
            spacing: 18,
            children: [
              for (var i = 0; i < items.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 120 * i),
                  child: HoverCard(
                    color: Colors.white.withValues(alpha: 0.05),
                    hoverColor: Colors.white.withValues(alpha: 0.09),
                    borderColor: Colors.white.withValues(alpha: 0.10),
                    hoverBorderColor: AppColors.warmAccent.withValues(
                      alpha: 0.7,
                    ),
                    padding: const EdgeInsets.all(24),
                    builder: (context, hovered) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrbitBadge(
                          icon: items[i].icon,
                          active: hovered,
                          dark: true,
                          size: 46,
                          activeFill: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          items[i].title,
                          style: AppText.heading(17, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          items[i].description,
                          style: AppText.body(
                            14.5,
                            color: Colors.white.withValues(alpha: 0.62),
                            height: 1.65,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 16),
                        ArrowLink(
                          label: 'Book this service',
                          color: AppColors.warmAccent,
                          onTap: () => onBookService(items[i].bookingLabel!),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.charcoalDeep,
            AppColors.charcoal,
            Color(0xFF2C3036),
          ],
        ),
        border: Border.all(color: AppColors.warmAccent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Only the decoration is clipped: content inside a clip would
          // never report itself visible, so its reveal would not start.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(31),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Starfield(count: 40, seed: 21),
                    ),
                    Positioned.fill(
                      child: Watermark(
                        right: mobile ? -160 : -90,
                        top: mobile ? -150 : -110,
                        child: YantraMandala(
                          size: mobile ? 360 : 500,
                          opacity: mobile ? 0.35 : 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }
}
