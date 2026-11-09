import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/icons/brand_icons.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';

/// Gold gradient used for highlighted words.
final Shader goldShader = const LinearGradient(
  colors: [Color(0xFFF0DDB4), AppColors.warmAccent, Color(0xFFA9824A)],
).createShader(const Rect.fromLTWH(0, 0, 520, 60));

class HeroSection extends StatefulWidget {
  const HeroSection({super.key, required this.onBook, required this.onExplore});

  final VoidCallback onBook;
  final VoidCallback onExplore;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  /// Pointer position across the hero, from -1 to 1 on each axis.
  final _pointer = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  /// Moves [child] with the pointer; deeper layers move more.
  Widget _parallax(double depth, Widget child) =>
      ValueListenableBuilder<Offset>(
        valueListenable: _pointer,
        child: child,
        builder: (context, p, child) => TweenAnimationBuilder<Offset>(
          tween: Tween(end: p * depth),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          child: child,
          builder: (context, o, child) =>
              Transform.translate(offset: o, child: child),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final desktop = context.isDesktop;
    final mobile = context.isMobile;
    final headline = AppText.heading(
      context.responsive(32.0, 44.0, 50.0),
      color: Colors.white,
      height: 1.14,
      letterSpacing: -1,
    );
    final gold = headline.copyWith(
      color: null,
      foreground: Paint()..shader = goldShader,
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          delay: const Duration(milliseconds: 100),
          offset: const Offset(-0.06, 0),
          child: _GlassPill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StarGlyph(size: 12),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    SiteContent.heroEyebrow,
                    style: AppText.eyebrow(
                      color: AppColors.warmAccent,
                      size: mobile ? 10.5 : 12,
                    ).copyWith(letterSpacing: mobile ? 2.4 : 3.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        Reveal(
          delay: const Duration(milliseconds: 250),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: SiteContent.heroHeadlineStart),
                TextSpan(text: SiteContent.heroHeadlineAccent1, style: gold),
                const TextSpan(text: SiteContent.heroHeadlineMiddle),
                TextSpan(text: SiteContent.heroHeadlineAccent2, style: gold),
              ],
            ),
            style: headline,
          ),
        ),
        const SizedBox(height: 26),
        Reveal(
          delay: const Duration(milliseconds: 420),
          child: Text(
            SiteContent.heroBody,
            style: AppText.body(
              mobile ? 15.5 : 16.5,
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.75,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Reveal(
          delay: const Duration(milliseconds: 560),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.warmAccent.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              SiteContent.heroSubText,
              style: AppText.body(
                mobile ? 14 : 15,
                color: Colors.white.withValues(alpha: 0.58),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Reveal(
          delay: const Duration(milliseconds: 700),
          child: Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              AppButton(
                label: 'Book a Consultation',
                icon: Icons.calendar_month_outlined,
                variant: AppButtonVariant.gold,
                onPressed: widget.onBook,
              ),
              AppButton(
                label: 'Chat on WhatsApp',
                icon: BrandIcons.whatsapp,
                variant: AppButtonVariant.outlineLight,
                onPressed: ContactLauncher.openWhatsApp,
              ),
            ],
          ),
        ),
        const SizedBox(height: 38),
        Reveal(
          delay: const Duration(milliseconds: 850),
          child: Wrap(
            spacing: 26,
            runSpacing: 12,
            children: [
              for (final h in SiteContent.heroHighlights)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(h.icon, size: 17, color: AppColors.warmAccent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        h.text,
                        style: AppText.body(
                          13.5,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );

    final wheelSize = min(540.0, screen.width * 0.38);

    return MouseRegion(
      onHover: (e) {
        final size = context.size;
        if (size == null) return;
        _pointer.value = Offset(
          e.localPosition.dx / size.width * 2 - 1,
          e.localPosition.dy / size.height * 2 - 1,
        );
      },
      onExit: (_) => _pointer.value = Offset.zero,
      child: Container(
        constraints: BoxConstraints(minHeight: max(screen.height, 700)),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.charcoalDeep,
              AppColors.charcoal,
              Color(0xFF262A30),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: _parallax(-10, const Nebula())),
            Positioned.fill(child: _parallax(-16, const Starfield(count: 100))),
            const Positioned.fill(child: IgnorePointer(child: ShootingStars())),
            if (!desktop)
              Positioned(
                right: -screen.width * 0.35,
                top: context.headerHeight + 20,
                child: IgnorePointer(
                  child: CosmicWheel(
                    size: screen.width * 0.95,
                    opacity: 0.3,
                    animate: false,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                top: context.headerHeight + (mobile ? 48 : 64),
                bottom: mobile ? 100 : 110,
              ),
              child: ContentWidth(
                maxWidth: 1240,
                child: desktop
                    ? Row(
                        children: [
                          Expanded(flex: 11, child: text),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 10,
                            child: Reveal(
                              delay: const Duration(milliseconds: 300),
                              offset: Offset.zero,
                              duration: const Duration(milliseconds: 1600),
                              child: _parallax(
                                22,
                                Center(child: _WheelWithTags(size: wheelSize)),
                              ),
                            ),
                          ),
                        ],
                      )
                    : text,
              ),
            ),
            // Fade into the next section.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.charcoalDeep.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 26,
              left: 0,
              right: 0,
              child: Center(child: _ScrollCue(onTap: widget.onExplore)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The rashi wheel with gently floating glass tags around it.
class _WheelWithTags extends StatelessWidget {
  const _WheelWithTags({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CosmicWheel(size: size, showRashis: true),
          Positioned(
            top: size * 0.04,
            left: -size * 0.08,
            child: const _FloatingTag(
              icon: Icons.track_changes,
              label: 'KP Astrology',
              phase: 0,
            ),
          ),
          Positioned(
            top: size * 0.46,
            right: -size * 0.12,
            child: const _FloatingTag(
              icon: Icons.auto_awesome_outlined,
              label: 'Advanced Vedic',
              phase: 2,
            ),
          ),
          Positioned(
            bottom: size * 0.02,
            left: size * 0.02,
            child: const _FloatingTag(
              icon: Icons.local_fire_department_outlined,
              label: 'Spiritual Poojas',
              phase: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTag extends StatefulWidget {
  const _FloatingTag({
    required this.icon,
    required this.label,
    required this.phase,
  });

  final IconData icon;
  final String label;
  final double phase;

  @override
  State<_FloatingTag> createState() => _FloatingTagState();
}

class _FloatingTagState extends LoopingAnimationState<_FloatingTag> {
  @override
  Duration get period => const Duration(seconds: 6);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, sin(controller.value * 2 * pi + widget.phase) * 8),
          child: child,
        ),
        child: _GlassPill(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warmAccent.withValues(alpha: 0.18),
                ),
                child: Icon(widget.icon, size: 16, color: AppColors.warmAccent),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppText.body(
                  13,
                  color: Colors.white,
                  weight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted glass capsule.
class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SizedBox(
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color(0xFF2A2E34).withValues(alpha: 0.85),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Bouncing "scroll" indicator at the bottom of the hero.
class _ScrollCue extends StatefulWidget {
  const _ScrollCue({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ScrollCue> createState() => _ScrollCueState();
}

class _ScrollCueState extends LoopingAnimationState<_ScrollCue> {
  @override
  Duration get period => const Duration(milliseconds: 3200);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Scroll to explore',
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                0,
                (0.5 - 0.5 * cos(controller.value * 2 * pi)) * 8,
              ),
              child: child,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCROLL',
                  style: AppText.eyebrow(
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
