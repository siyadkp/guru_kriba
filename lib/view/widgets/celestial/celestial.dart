import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';

Path _starPath(Offset c, double r, {double waist = 0.22}) {
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final a = -pi / 2 + i * pi / 4;
    final rr = i.isEven ? r : r * waist;
    final p = c + Offset(cos(a), sin(a)) * rr;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

// ---------------------------------------------------------------- STAR GLYPH

/// A four-point sparkle star ✦ drawn as a shape (renders identically
/// everywhere, unlike the Unicode character).
class StarGlyph extends StatelessWidget {
  const StarGlyph({
    super.key,
    this.size = 10,
    this.color = AppColors.warmAccent,
  });
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _StarGlyphPainter(color));
}

class _StarGlyphPainter extends CustomPainter {
  _StarGlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _starPath(size.center(Offset.zero), size.shortestSide / 2),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_StarGlyphPainter old) => old.color != color;
}

// ----------------------------------------------------------- CELESTIAL RULE

/// ── ✦ ── ornament used under section titles.
class CelestialDivider extends StatelessWidget {
  const CelestialDivider({
    super.key,
    this.lineWidth = 46,
    this.color = AppColors.warmAccent,
  });

  final double lineWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget line(bool fadeLeft) => Container(
      width: lineWidth,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: fadeLeft
              ? [color.withValues(alpha: 0), color]
              : [color, color.withValues(alpha: 0)],
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(true),
        const SizedBox(width: 8),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 6),
        StarGlyph(size: 11, color: color),
        const SizedBox(width: 6),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 8),
        line(false),
      ],
    );
  }
}

// --------------------------------------------------------------- ORBIT BADGE

/// An icon inside a "planet" with an orbit ring. While [active] (hovered),
/// a golden moon circles the orbit.
class OrbitBadge extends StatefulWidget {
  const OrbitBadge({
    super.key,
    required this.icon,
    this.active = false,
    this.dark = false,
    this.size = 54,
    this.activeFill = AppColors.charcoal,
  });

  final IconData icon;
  final bool active;

  /// True when shown on a dark background.
  final bool dark;
  final double size;
  final Color activeFill;

  @override
  State<OrbitBadge> createState() => _OrbitBadgeState();
}

class _OrbitBadgeState extends State<OrbitBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(OrbitBadge old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.size + 20;
    final idle = widget.dark
        ? Colors.white.withValues(alpha: 0.07)
        : AppColors.platinum;
    return SizedBox.square(
      dimension: total,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(total),
            painter: _OrbitPainter(_c, widget.active, widget.dark),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.active ? widget.activeFill : idle,
              gradient: widget.active
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        idle,
                        widget.dark
                            ? Colors.white.withValues(alpha: 0.02)
                            : AppColors.hairline,
                      ],
                    ),
              boxShadow: widget.active
                  ? [
                      BoxShadow(
                        color: AppColors.warmAccent.withValues(alpha: 0.35),
                        blurRadius: 22,
                      ),
                    ]
                  : const [],
            ),
            child: Icon(
              widget.icon,
              size: widget.size * 0.44,
              color: widget.active
                  ? AppColors.warmAccent
                  : (widget.dark
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.slate),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.animation, this.active, this.dark)
    : super(repaint: animation);
  final Animation<double> animation;
  final bool active;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 3;
    final base = dark ? Colors.white : AppColors.slate;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = active
            ? AppColors.warmAccent.withValues(alpha: 0.6)
            : base.withValues(alpha: 0.16),
    );
    final a = -pi / 2 + animation.value * 2 * pi;
    final p = c + Offset(cos(a), sin(a)) * r;
    if (active) {
      canvas.drawCircle(
        p,
        7,
        Paint()..color = AppColors.warmAccent.withValues(alpha: 0.25),
      );
    }
    canvas.drawCircle(
      p,
      active ? 3.2 : 2.2,
      Paint()
        ..color = active ? AppColors.warmAccent : base.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.active != active || old.dark != dark;
}

// ----------------------------------------------------------- CURSOR SPARKLES

class _Sparkle {
  _Sparkle(this.pos, this.vel, this.born, this.life, this.size, this.warm);
  final Offset pos, vel;
  final Duration born, life;
  final double size;
  final bool warm;
}

/// Leaves a short trail of golden stardust behind the mouse pointer.
/// Touch input is ignored, and the ticker only runs while dust is visible.
class CursorSparkles extends StatefulWidget {
  const CursorSparkles({super.key, required this.child});
  final Widget child;

  @override
  State<CursorSparkles> createState() => _CursorSparklesState();
}

class _CursorSparklesState extends State<CursorSparkles>
    with SingleTickerProviderStateMixin {
  final _particles = <_Sparkle>[];
  final _repaint = ValueNotifier<int>(0);
  final _rand = Random();
  late final Ticker _ticker = createTicker(_tick);
  Duration _now = Duration.zero;
  Offset? _last;

  void _tick(Duration elapsed) {
    _now = elapsed;
    _particles.removeWhere((p) => elapsed - p.born > p.life);
    _repaint.value++;
    if (_particles.isEmpty) _ticker.stop();
  }

  void _onPointer(PointerEvent e) {
    if (e.kind != PointerDeviceKind.mouse) return;
    final pos = e.localPosition;
    if (_last != null && (pos - _last!).distance < 16) return;
    _last = pos;
    if (_particles.length > 48) return;
    if (!_ticker.isActive) {
      _now = Duration.zero;
      _ticker.start();
    }
    for (var i = 0; i < 2; i++) {
      _particles.add(
        _Sparkle(
          pos + Offset(_rand.nextDouble() * 8 - 4, _rand.nextDouble() * 8 - 4),
          Offset((_rand.nextDouble() - 0.5) * 36, 14 + _rand.nextDouble() * 26),
          _now,
          Duration(milliseconds: 650 + _rand.nextInt(500)),
          1.6 + _rand.nextDouble() * 3.4,
          _rand.nextDouble() < 0.8,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerHover: _onPointer,
          onPointerMove: _onPointer,
          child: widget.child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SparklePainter(_particles, () => _now, _repaint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.particles, this.now, Listenable repaint)
    : super(repaint: repaint);
  final List<_Sparkle> particles;
  final Duration Function() now;

  @override
  void paint(Canvas canvas, Size size) {
    final t = now();
    final paint = Paint();
    for (final p in particles) {
      final age = ((t - p.born).inMicroseconds / p.life.inMicroseconds).clamp(
        0.0,
        1.0,
      );
      final seconds = (t - p.born).inMicroseconds / 1e6;
      final pos = p.pos + p.vel * seconds;
      final s = p.size * (1 - age * 0.6);
      paint.color = (p.warm ? AppColors.warmAccent : const Color(0xFFFFF3DC))
          .withValues(alpha: (1 - age) * 0.9);
      if (s > 3) {
        canvas.drawPath(_starPath(pos, s * 1.4), paint);
      } else {
        canvas.drawCircle(pos, s * 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => false;
}
