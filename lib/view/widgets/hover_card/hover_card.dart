import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';

/// A rounded card that lifts and casts a shadow on hover.
///
/// Performance: no blurred shadow while idle (a border outlines it), and
/// hover is ignored while the page is scrolling, so cards sliding under a
/// still mouse don't start animations mid-scroll.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.builder,
    this.color = Colors.white,
    this.hoverColor,
    this.borderColor = AppColors.hairline,
    this.hoverBorderColor = const Color(0x664A5568),
    this.padding = const EdgeInsets.all(28),
    this.radius = 22,
    this.onTap,
  });

  final Widget Function(BuildContext context, bool hovered) builder;
  final Color color;
  final Color? hoverColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (value && PageScroll.isScrolling.value) return;
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _hovered ? (widget.hoverColor ?? widget.color) : widget.color,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: _hovered ? widget.hoverBorderColor : widget.borderColor,
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ]
            : const [],
      ),
      child: widget.builder(context, _hovered),
    );

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onHover: (_) {
        // The pointer moved over the card after scrolling stopped.
        if (!_hovered) _setHovered(true);
      },
      onExit: (_) => _setHovered(false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: widget.onTap == null
          ? card
          : GestureDetector(onTap: widget.onTap, child: card),
    );
  }
}
