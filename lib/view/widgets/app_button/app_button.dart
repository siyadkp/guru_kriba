import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';

enum AppButtonVariant {
  /// Charcoal fill, for light backgrounds.
  dark,

  /// White fill, for dark backgrounds.
  light,

  /// Outline, for light backgrounds.
  outlineDark,

  /// Outline, for dark backgrounds.
  outlineLight,

  /// WhatsApp green fill.
  whatsapp,

  /// Warm gold gradient — the main call to action on dark backgrounds.
  gold,
}

const _goldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF0DDB4), AppColors.warmAccent, Color(0xFFB08A4F)],
);

/// Pill-shaped call-to-action button with a hover lift.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.dark,
    this.icon,
    this.faIcon,
    this.compact = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final FaIconData? faIcon;
  final bool compact;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  ({Color bg, Color fg, Color border}) _colors() {
    final h = _hovered;
    switch (widget.variant) {
      case AppButtonVariant.dark:
        return (
          bg: h ? AppColors.slate : AppColors.charcoal,
          fg: Colors.white,
          border: Colors.transparent,
        );
      case AppButtonVariant.light:
        return (
          bg: h ? AppColors.platinum : Colors.white,
          fg: AppColors.charcoal,
          border: Colors.transparent,
        );
      case AppButtonVariant.outlineDark:
        return (
          bg: h ? AppColors.charcoal : Colors.transparent,
          fg: h ? Colors.white : AppColors.charcoal,
          border: AppColors.charcoal,
        );
      case AppButtonVariant.outlineLight:
        return (
          bg: h ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
          fg: Colors.white,
          border: Colors.white.withValues(alpha: h ? 0.9 : 0.45),
        );
      case AppButtonVariant.whatsapp:
        return (
          bg: h ? const Color(0xFF1EBE5A) : AppColors.whatsapp,
          fg: Colors.white,
          border: Colors.transparent,
        );
      case AppButtonVariant.gold:
        return (
          bg: AppColors.warmAccent,
          fg: AppColors.charcoal,
          border: Colors.white.withValues(alpha: h ? 0.6 : 0.25),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors();
    final filled =
        widget.variant != AppButtonVariant.outlineDark &&
        widget.variant != AppButtonVariant.outlineLight;
    final iconSize = widget.compact ? 16.0 : 18.0;

    final Widget? icon = widget.faIcon != null
        ? FaIcon(widget.faIcon, size: iconSize, color: c.fg)
        : widget.icon != null
        ? Icon(widget.icon, size: iconSize, color: c.fg)
        : null;

    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (v) {
            // Ignore cards sliding under a still mouse mid-scroll.
            if (v && PageScroll.isScrolling.value) return;
            setState(() => _hovered = v);
          },
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.white24,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 18 : 28,
              vertical: widget.compact ? 12 : 18,
            ),
            decoration: BoxDecoration(
              color: c.bg,
              gradient: widget.variant == AppButtonVariant.gold
                  ? _goldGradient
                  : null,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: c.border, width: 1.2),
              boxShadow: filled && _hovered
                  ? [
                      BoxShadow(
                        color: c.bg.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon, const SizedBox(width: 10)],
                Flexible(
                  child: Text(
                    widget.label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      widget.compact ? 12 : 13,
                      color: c.fg,
                      weight: FontWeight.w600,
                      letterSpacing: 1.3,
                      height: 1.2,
                    ),
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

/// Small text link with an arrow that slides on hover.
class ArrowLink extends StatefulWidget {
  const ArrowLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.charcoal,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  State<ArrowLink> createState() => _ArrowLinkState();
}

class _ArrowLinkState extends State<ArrowLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) {
        // Ignore cards sliding under a still mouse mid-scroll.
        if (v && PageScroll.isScrolling.value) return;
        setState(() => _hovered = v);
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.label,
                style: AppText.body(
                  13.5,
                  color: widget.color,
                  weight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.2,
                ),
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(left: _hovered ? 12 : 6),
              child: Icon(Icons.arrow_forward, size: 16, color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}
