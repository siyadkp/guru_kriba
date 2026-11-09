import 'package:flutter/material.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/constants/app_contact.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/brand_mark/brand_mark.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, required this.onNavigate});

  final ValueChanged<SiteSection> onNavigate;

  static const _links = [
    ('Home', SiteSection.home),
    ('About Us', SiteSection.about),
    ('Services', SiteSection.services),
    ('Book Consultation', SiteSection.booking),
    ('FAQ', SiteSection.faq),
    ('Contact Us', SiteSection.contact),
  ];

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy', style: AppText.heading(22)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            SiteContent.privacyCommitment,
            style: AppText.body(15, color: AppColors.slate),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: AppText.body(
                13,
                color: AppColors.charcoal,
                weight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final muted = Colors.white.withValues(alpha: 0.6);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        text.toUpperCase(),
        style: AppText.eyebrow(color: AppColors.warmAccent, size: 11.5),
      ),
    );

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandLogo(color: Colors.white),
        const SizedBox(height: 22),
        Text(
          SiteContent.footerDescription,
          style: AppText.body(14.5, color: muted),
        ),
      ],
    );

    final links = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Quick Links'),
        for (final (label, section) in _links)
          _FooterLink(label: label, onTap: () => onNavigate(section)),
        _FooterLink(
          label: 'Privacy Policy',
          onTap: () => _showPrivacy(context),
        ),
      ],
    );

    final privacy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Privacy Commitment'),
        Text(
          SiteContent.privacyCommitment,
          style: AppText.body(14.5, color: muted),
        ),
        const SizedBox(height: 22),
        _FooterLink(
          label: AppContact.phoneDisplay,
          icon: Icons.phone_outlined,
          onTap: ContactLauncher.call,
        ),
        _FooterLink(
          label: AppContact.email,
          icon: Icons.mail_outline,
          onTap: () => ContactLauncher.email(subject: 'Consultation Enquiry'),
        ),
      ],
    );

    return Container(
      color: AppColors.charcoalDeep,
      child: Stack(
        children: [
          const Positioned.fill(child: Starfield(count: 45, seed: 23)),
          Positioned.fill(
            child: Watermark(
              right: -200,
              top: -180,
              child: CosmicWheel(size: 560, opacity: 0.12, animate: false),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: context.isMobile ? 64 : 88,
              bottom: 28,
            ),
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: brand),
                        const SizedBox(width: 64),
                        Expanded(flex: 3, child: links),
                        const SizedBox(width: 48),
                        Expanded(flex: 4, child: privacy),
                      ],
                    )
                  else ...[
                    brand,
                    const SizedBox(height: 44),
                    links,
                    const SizedBox(height: 36),
                    privacy,
                  ],
                  const SizedBox(height: 56),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '© ${DateTime.now().year} ${SiteContent.brandName}. '
                    'All rights reserved.',
                    style: AppText.body(
                      13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    SiteContent.healthDisclaimer,
                    style: AppText.body(
                      12,
                      color: Colors.white.withValues(alpha: 0.38),
                      height: 1.5,
                    ),
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

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: _hovered ? 1 : 0.7);
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) => setState(() => _hovered = v),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(left: _hovered ? 6 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: color),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: AppText.body(14.5, color: color, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
