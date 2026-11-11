import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/icons/brand_icons.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/constants/app_contact.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/brand_mark/brand_mark.dart';

/// Sections shown as links in the desktop header (booking is the button).
List<SiteSection> get _navSections => [
  for (final s in SiteContent.visibleSections)
    if (s != SiteSection.booking) s,
];

/// Sticky header: transparent over the hero, frosted off-white once the
/// visitor scrolls. The "Book a Consultation" button is always visible.
class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.solid,
    required this.active,
    required this.onNavigate,
    required this.onMenu,
    required this.progress,
  });

  /// How far down the page the visitor has scrolled, 0–1.
  final ValueListenable<double> progress;

  final bool solid;
  final SiteSection active;
  final ValueChanged<SiteSection> onNavigate;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? AppColors.charcoal : Colors.white;
    final fullNav = context.showFullNav;

    final bar = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: context.headerHeight,
      decoration: BoxDecoration(
        color: solid
            ? AppColors.offWhite.withValues(alpha: 0.97)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: solid ? AppColors.hairline : Colors.transparent,
          ),
        ),
        boxShadow: solid
            ? [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: ContentWidth(
        maxWidth: 1280,
        child: Row(
          children: [
            // Without the full menu the logo takes all the free space, so it
            // only shrinks when the screen is genuinely too narrow.
            Flexible(
              fit: fullNav ? FlexFit.loose : FlexFit.tight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Guru Kripa Astro Science – back to top',
                  child: InkWell(
                    onTap: () => onNavigate(SiteSection.home),
                    borderRadius: BorderRadius.circular(8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: BrandLogo(
                        color: fg,
                        scale: context.isMobile ? 0.85 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (fullNav)
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  // Scales the links down rather than overflowing.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        for (final s in _navSections)
                          _NavLink(
                            label: s.label,
                            active: s == active,
                            color: fg,
                            onTap: () => onNavigate(s),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(width: fullNav ? 20 : 8),
            AppButton(
              label: context.isMobile ? 'Book' : 'Book a Consultation',
              icon: Icons.calendar_month_outlined,
              compact: true,
              variant: solid ? AppButtonVariant.dark : AppButtonVariant.gold,
              onPressed: () => onNavigate(SiteSection.booking),
            ),
            if (!fullNav) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Menu',
                onPressed: onMenu,
                icon: Icon(Icons.menu_rounded, color: fg, size: 28),
              ),
            ],
          ],
        ),
      ),
    );

    return RepaintBoundary(
      child: SizedBox(
        child: Stack(
          children: [
            bar,
            // Golden reading-progress line.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: solid ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: ValueListenableBuilder<double>(
                  valueListenable: progress,
                  builder: (context, p, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: p.clamp(0.0, 1.0),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0x00C9A46A), AppColors.warmAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.warmAccent.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) => setState(() => _hovered = v),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: AppText.body(
                14,
                color: widget.color.withValues(alpha: highlighted ? 1 : 0.72),
                weight: widget.active ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: 2,
              width: widget.active ? 22 : (_hovered ? 12 : 0),
              decoration: BoxDecoration(
                color: AppColors.warmAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide-in menu for phones and tablets.
class MobileNavDrawer extends StatelessWidget {
  const MobileNavDrawer({
    super.key,
    required this.active,
    required this.onNavigate,
  });

  final SiteSection active;
  final ValueChanged<SiteSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    void go(SiteSection s) {
      Navigator.of(context).pop();
      onNavigate(s);
    }

    return Drawer(
      backgroundColor: AppColors.charcoal,
      width: 320,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandLogo(color: Colors.white, scale: 0.9),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    for (final s in SiteContent.visibleSections)
                      _DrawerItem(
                        label: s.label,
                        active: s == active,
                        onTap: () => go(s),
                      ),
                  ],
                ),
              ),
              AppButton(
                label: 'Book a Consultation',
                icon: Icons.calendar_month_outlined,
                variant: AppButtonVariant.light,
                expand: true,
                onPressed: () => go(SiteSection.booking),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Chat on WhatsApp',
                icon: BrandIcons.whatsapp,
                variant: AppButtonVariant.whatsapp,
                expand: true,
                onPressed: ContactLauncher.openWhatsApp,
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  AppContact.phoneDisplay,
                  style: AppText.body(13, color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 18 : 0,
              height: 2,
              margin: EdgeInsets.only(right: active ? 12 : 0),
              color: AppColors.warmAccent,
            ),
            Text(
              label,
              style: AppText.heading(
                17,
                color: active ? Colors.white : Colors.white70,
                weight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
