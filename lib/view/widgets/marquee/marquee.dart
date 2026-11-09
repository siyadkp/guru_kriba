import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';

/// Endless horizontally scrolling strip of labels separated by ✦ stars.
///
/// The strip is built and rasterised once; each frame only moves it, so
/// scrolling text costs almost nothing. Pauses on hover and off-screen.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.items,
    this.speed = 45,
    this.reverse = false,
    this.style,
    this.height = 64,
    this.gap = 26,
    this.starSize = 12,
    this.fadeColor = AppColors.charcoalDeep,
  });

  final List<String> items;

  /// Pixels per second.
  final double speed;
  final bool reverse;
  final TextStyle? style;
  final double height;
  final double gap;
  final double starSize;

  /// Background colour the edges fade into.
  final Color fadeColor;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with ViewportAware<Marquee> {
  final GlobalKey _firstCopy = GlobalKey();
  final _offset = ValueNotifier<double>(0);
  double _copyWidth = 0;
  bool _hovered = false;
  bool _listening = false;
  Duration? _last;

  @override
  void onViewportChanged(bool visible) {
    if (visible && !_listening) {
      _listening = true;
      _last = null;
      FrameClock.instance.addListener(_tick);
    } else if (!visible && _listening) {
      _listening = false;
      FrameClock.instance.removeListener(_tick);
    }
  }

  void _tick() {
    final elapsed = FrameClock.instance.elapsed;
    final dt = _last == null ? 0.0 : (elapsed - _last!).inMicroseconds / 1e6;
    _last = elapsed;
    if (_hovered) return;
    if (_copyWidth == 0) {
      final box = _firstCopy.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      _copyWidth = box.size.width;
    }
    _offset.value = (_offset.value + dt * widget.speed) % _copyWidth;
  }

  @override
  void dispose() {
    if (_listening) FrameClock.instance.removeListener(_tick);
    _offset.dispose();
    super.dispose();
  }

  Widget _copy({Key? key}) {
    final style =
        widget.style ??
        AppText.heading(18, color: AppColors.slate, weight: FontWeight.w500);
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in widget.items)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StarGlyph(size: widget.starSize),
                SizedBox(width: widget.gap * 0.6),
                Text(item, style: style),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strip = RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _copy(key: _firstCopy),
          _copy(),
          _copy(),
        ],
      ),
    );

    Widget fade(bool left) => Positioned(
      top: 0,
      bottom: 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      width: 90,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: left ? Alignment.centerLeft : Alignment.centerRight,
              end: left ? Alignment.centerRight : Alignment.centerLeft,
              colors: [widget.fadeColor, widget.fadeColor.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => _hovered = true,
      onExit: (_) => _hovered = false,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _offset,
                    child: strip,
                    builder: (context, offset, child) {
                      final dx = widget.reverse
                          ? -(_copyWidth == 0 ? 0.0 : _copyWidth - offset)
                          : -offset;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                  ),
                ),
              ),
            ),
            fade(true),
            fade(false),
          ],
        ),
      ),
    );
  }
}
