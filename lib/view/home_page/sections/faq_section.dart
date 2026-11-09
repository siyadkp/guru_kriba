import 'package:flutter/material.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/utils/icons/brand_icons.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _open = 0;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final faqs = SiteContent.faqs;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'FAQ',
          title: 'Frequently Asked Questions',
          subtitle:
              'Answers to common questions about consultations, spiritual '
              'services, and booking.',
        ),
        const SizedBox(height: 32),
        Reveal(
          delay: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.platinum,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Still have a question?', style: AppText.heading(19)),
                const SizedBox(height: 8),
                Text(
                  'Message us on WhatsApp and we will guide you.',
                  style: AppText.body(14.5, color: AppColors.mediumGray),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Ask on WhatsApp',
                  icon: BrandIcons.whatsapp,
                  variant: AppButtonVariant.dark,
                  compact: true,
                  onPressed: ContactLauncher.openWhatsApp,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final list = Column(
      children: [
        for (var i = 0; i < faqs.length; i++)
          Reveal(
            delay: Duration(milliseconds: 80 * i),
            child: _FaqTile(
              item: faqs[i],
              open: _open == i,
              onTap: () => setState(() => _open = _open == i ? null : i),
            ),
          ),
      ],
    );

    return SectionShell(
      background: Colors.white,
      backdrop: const ConstellationField(seed: 9, clusters: 4, opacity: 0.6),
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: intro),
                const SizedBox(width: 64),
                Expanded(flex: 6, child: list),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [intro, const SizedBox(height: 40), list],
            ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item, required this.open, required this.onTap});

  final FaqItem item;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: open ? AppColors.offWhite : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: open
              ? AppColors.slate.withValues(alpha: 0.4)
              : AppColors.hairline,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.question,
                        style: AppText.heading(16.5, weight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedRotation(
                      turns: open ? 0.125 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: open ? AppColors.charcoal : AppColors.platinum,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: open ? Colors.white : AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: open
                        ? Padding(
                            padding: const EdgeInsets.only(top: 14, right: 40),
                            child: Text(
                              item.answer,
                              style: AppText.body(15, color: AppColors.slate),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
