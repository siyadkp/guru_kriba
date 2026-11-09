import 'package:flutter/material.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/utils/icons/brand_icons.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/constants/app_contact.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/hover_card/hover_card.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(1, 2, 4);
    final cards =
        <({IconData icon, String label, String value, VoidCallback? onTap})>[
          (
            icon: Icons.phone_in_talk_outlined,
            label: 'Phone / WhatsApp',
            value: AppContact.phoneDisplay,
            onTap: ContactLauncher.call,
          ),
          (
            icon: Icons.mail_outline,
            label: 'Email Address',
            value: AppContact.email,
            onTap: () => ContactLauncher.email(subject: 'Consultation Enquiry'),
          ),
          (
            icon: Icons.location_on_outlined,
            label: 'Office Location',
            value: AppContact.officeLocation,
            onTap: null,
          ),
          (
            icon: Icons.videocam_outlined,
            label: 'Consultation Format',
            value: AppContact.consultationFormat,
            onTap: null,
          ),
        ];

    return SectionShell(
      background: AppColors.platinum,
      backdrop: const ConstellationField(seed: 11, opacity: 0.9),
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'Contact Us',
            title: 'Get in Touch',
            subtitle: SiteContent.contactIntro,
            centered: true,
          ),
          const SizedBox(height: 52),
          ResponsiveGrid(
            columns: cols,
            spacing: 20,
            children: [
              for (var i = 0; i < cards.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 90 * (i % cols)),
                  child: HoverCard(
                    onTap: cards[i].onTap,
                    padding: const EdgeInsets.all(26),
                    builder: (context, hovered) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrbitBadge(
                          icon: cards[i].icon,
                          active: hovered,
                          size: 46,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          cards[i].label.toUpperCase(),
                          style: AppText.eyebrow(
                            color: AppColors.mediumGray,
                            size: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cards[i].value,
                          style: AppText.heading(
                            15.5,
                            weight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 44),
          Reveal(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                const AppButton(
                  label: 'Call Now',
                  icon: Icons.call_outlined,
                  variant: AppButtonVariant.dark,
                  onPressed: ContactLauncher.call,
                ),
                const AppButton(
                  label: 'WhatsApp Us',
                  icon: BrandIcons.whatsapp,
                  variant: AppButtonVariant.whatsapp,
                  onPressed: ContactLauncher.openWhatsApp,
                ),
                AppButton(
                  label: 'Send an Enquiry',
                  icon: Icons.mail_outline,
                  variant: AppButtonVariant.outlineDark,
                  onPressed: () =>
                      ContactLauncher.email(subject: 'Consultation Enquiry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
