import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';

/// Drives a slow, endlessly looping animation as cheaply as possible:
/// - it is driven by the shared 30 fps [FrameClock] instead of its own
///   display-rate ticker, so idle pages render half as many frames,
/// - it only listens while the widget is on screen,
/// - with [animates] false it draws one still frame and never updates.
///
/// [controller] holds the loop position from 0 to 1.
abstract class LoopingAnimationState<T extends StatefulWidget> extends State<T>
    with ViewportAware<T> {
  Duration get period;
  bool get animates => true;

  final ValueNotifier<double> controller = ValueNotifier<double>(0);
  bool _listening = false;

  @override
  double get viewportMargin => 150;

  @override
  void initState() {
    super.initState();
    if (!animates) stopWatchingViewport();
  }

  void _tick() {
    final t = FrameClock.instance.elapsed.inMicroseconds;
    controller.value = (t % period.inMicroseconds) / period.inMicroseconds;
  }

  @override
  void onViewportChanged(bool visible) {
    if (!animates) return;
    if (visible && !_listening) {
      _listening = true;
      FrameClock.instance.addListener(_tick);
    } else if (!visible && _listening) {
      _listening = false;
      FrameClock.instance.removeListener(_tick);
    }
  }

  @override
  void dispose() {
    if (_listening) FrameClock.instance.removeListener(_tick);
    controller.dispose();
    super.dispose();
  }
}

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

/// A soft halo around a point — two translucent circles instead of a blur
/// filter, which is far cheaper to draw every frame.
void _halo(Canvas canvas, Offset p, double r, Color color) {
  canvas.drawCircle(p, r * 2.6, Paint()..color = color.withValues(alpha: 0.10));
  canvas.drawCircle(p, r * 1.7, Paint()..color = color.withValues(alpha: 0.22));
}

Shader _radialGlow(Offset c, double r, Color color, double alpha) =>
    RadialGradient(
      colors: [
        color.withValues(alpha: alpha),
        color.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: c, radius: r));

// ---------------------------------------------------------------- STARFIELD

class _Star {
  _Star(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      radius = 0.4 + r.nextDouble() * 1.3,
      phase = r.nextDouble() * 2 * pi,
      speed = 1 + r.nextInt(4),
      warm = r.nextDouble() < 0.12;

  final double x, y, radius, phase;
  final int speed;
  final bool warm;
}

/// Twinkling, slowly rising stars for dark backgrounds.
class Starfield extends StatefulWidget {
  const Starfield({super.key, this.count = 80, this.seed = 7});
  final int count;
  final int seed;

  @override
  State<Starfield> createState() => _StarfieldState();
}

class _StarfieldState extends LoopingAnimationState<Starfield> {
  @override
  Duration get period => const Duration(seconds: 40);

  late final List<_Star> _stars = () {
    final r = Random(widget.seed);
    return List.generate(widget.count, (_) => _Star(r));
  }();

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _StarfieldPainter(controller, _stars),
      size: Size.infinite,
    ),
  );
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter(this.animation, this.stars) : super(repaint: animation);
  final ValueListenable<double> animation;
  final List<_Star> stars;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (final s in stars) {
      // Integer speeds keep the loop seamless.
      final twinkle = 0.5 + 0.5 * sin(t * 2 * pi * s.speed * 3 + s.phase);
      _paint.color = (s.warm ? AppColors.warmAccent : Colors.white).withValues(
        alpha: 0.15 + 0.7 * twinkle,
      );
      final y = (s.y - t * 0.05 * s.speed) % 1.0;
      final p = Offset(s.x * size.width, y * size.height);
      if (s.radius > 1.5 && twinkle > 0.8) {
        canvas.drawPath(_starPath(p, s.radius * 3.2), _paint);
      } else {
        canvas.drawCircle(p, s.radius, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => false;
}

// ----------------------------------------------------------- CONSTELLATIONS

class _Cluster {
  _Cluster(Random r)
    : center = Offset(r.nextDouble(), r.nextDouble()),
      phase = r.nextDouble() * 2 * pi,
      points = [] {
    final n = 4 + r.nextInt(4);
    var p = Offset.zero;
    var heading = r.nextDouble() * 2 * pi;
    points.add(p);
    for (var i = 1; i < n; i++) {
      heading += (r.nextDouble() - 0.5) * 1.6;
      p += Offset(cos(heading), sin(heading)) * (30 + r.nextDouble() * 46);
      points.add(p);
    }
    if (r.nextBool()) {
      branch = 1 + r.nextInt(n - 1);
      final a = r.nextDouble() * 2 * pi;
      branchPoint = points[branch!] + Offset(cos(a), sin(a)) * 40;
    }
  }

  final Offset center;
  final double phase;
  final List<Offset> points;
  int? branch;
  Offset? branchPoint;
}

/// Faint constellations — joined star clusters. Drawn once as a still
/// image (they sit behind text, where motion would only cost speed).
class ConstellationField extends StatefulWidget {
  const ConstellationField({
    super.key,
    this.color = AppColors.slate,
    this.clusters = 6,
    this.looseStars = 46,
    this.seed = 1,
    this.opacity = 1,
  });

  final Color color;
  final int clusters;
  final int looseStars;
  final int seed;
  final double opacity;

  @override
  State<ConstellationField> createState() => _ConstellationFieldState();
}

class _ConstellationFieldState extends State<ConstellationField> {
  late final Random _r = Random(widget.seed);
  late final List<_Cluster> _clusters = List.generate(
    widget.clusters,
    (_) => _Cluster(_r),
  );
  late final List<_Star> _loose = List.generate(
    widget.looseStars,
    (_) => _Star(_r),
  );

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.infinite,
      isComplex: true,
      painter: _ConstellationPainter(
        _clusters,
        _loose,
        widget.color,
        widget.opacity,
      ),
    ),
  );
}

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter(this.clusters, this.loose, this.color, this.opacity);

  final List<_Cluster> clusters;
  final List<_Star> loose;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: 0.16 * opacity);
    final dot = Paint();

    for (final c in clusters) {
      final origin = Offset(
        c.center.dx * size.width,
        c.center.dy * size.height,
      );
      final pts = [for (final p in c.points) origin + p];
      for (var i = 1; i < pts.length; i++) {
        canvas.drawLine(pts[i - 1], pts[i], line);
      }
      if (c.branch != null) {
        canvas.drawLine(pts[c.branch!], origin + c.branchPoint!, line);
        pts.add(origin + c.branchPoint!);
      }
      for (var i = 0; i < pts.length; i++) {
        final tw = 0.5 + 0.5 * sin(c.phase + i * 1.3);
        dot.color = color.withValues(alpha: (0.30 + 0.45 * tw) * opacity);
        canvas.drawCircle(pts[i], i == 0 ? 2.4 : 1.6, dot);
        if (i == 0) {
          dot.color = AppColors.warmAccent.withValues(alpha: 0.75 * opacity);
          canvas.drawPath(_starPath(pts[i], 6), dot);
        }
      }
    }

    for (final s in loose) {
      final tw = 0.5 + 0.5 * sin(s.phase);
      dot.color = color.withValues(alpha: (0.10 + 0.28 * tw) * opacity);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius * 0.9,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter old) =>
      old.color != color || old.opacity != opacity;
}

// --------------------------------------------------------- SHOOTING STARS

/// An occasional meteor streaking across a dark sky.
class ShootingStars extends StatefulWidget {
  const ShootingStars({super.key});

  @override
  State<ShootingStars> createState() => _ShootingStarsState();
}

class _ShootingStarsState extends LoopingAnimationState<ShootingStars> {
  @override
  Duration get period => const Duration(seconds: 9);

  int _cycle = 0;
  double _last = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.value < _last) _cycle++;
      _last = controller.value;
    });
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.infinite,
      painter: _MeteorPainter(controller, () => _cycle),
    ),
  );
}

class _MeteorPainter extends CustomPainter {
  _MeteorPainter(this.animation, this.cycle) : super(repaint: animation);
  final ValueListenable<double> animation;
  final int Function() cycle;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (var k = 0; k < 2; k++) {
      final r = Random(cycle() * 31 + k * 101);
      final start = k * 0.45 + r.nextDouble() * 0.3;
      final local = (t - start) / 0.13;
      if (local < 0 || local > 1) continue;
      final origin = Offset(
        size.width * (0.35 + r.nextDouble() * 0.65),
        size.height * r.nextDouble() * 0.4,
      );
      final angle = pi * (0.76 + r.nextDouble() * 0.1);
      final dir = Offset(cos(angle), sin(angle));
      final travel = size.shortestSide * 0.55;
      final head = origin + dir * travel * Curves.easeOut.transform(local);
      final tail = head - dir * (140 * (1 - local * 0.4));
      final fade = local < 0.2 ? local / 0.2 : (1 - local) / 0.8;
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.85 * fade),
            ],
          ).createShader(Rect.fromPoints(tail, head)),
      );
      canvas.drawCircle(
        head,
        2.2,
        Paint()..color = const Color(0xFFFFF3DC).withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_MeteorPainter old) => false;
}

// ------------------------------------------------------------------ NEBULA

/// Soft clouds of light for dark sections, drawn once.
class Nebula extends StatelessWidget {
  const Nebula({super.key, this.intensity = 1});
  final double intensity;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.infinite,
      isComplex: true,
      painter: _NebulaPainter(intensity),
    ),
  );
}

class _NebulaPainter extends CustomPainter {
  _NebulaPainter(this.intensity);
  final double intensity;

  static const _clouds = [
    (color: AppColors.warmAccent, alpha: 0.10, x: 0.78, y: 0.22),
    (color: Color(0xFF8A9BB8), alpha: 0.09, x: 0.18, y: 0.7),
    (color: AppColors.warmAccent, alpha: 0.06, x: 0.45, y: 0.95),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in _clouds) {
      final center = Offset(size.width * c.x, size.height * c.y);
      final radius = size.longestSide * 0.42;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = _radialGlow(center, radius, c.color, c.alpha * intensity),
      );
    }
  }

  @override
  bool shouldRepaint(_NebulaPainter old) => old.intensity != intensity;
}

// -------------------------------------------------------------- COSMIC WHEEL

/// The twelve Vedic rashis, shown around the hero wheel.
const List<String> rashiNames = [
  'MESHA', 'VRISHABHA', 'MITHUNA', 'KARKA', 'SIMHA', 'KANYA', //
  'TULA', 'VRISHCHIKA', 'DHANU', 'MAKARA', 'KUMBHA', 'MEENA',
];

/// A rotating astrological wheel: 27 nakshatra ticks, 12 houses, orbiting
/// planets and a glowing centre, optionally labelled with the rashis.
/// [color] sets the line colour; set [animate] false for still watermarks.
class CosmicWheel extends StatefulWidget {
  const CosmicWheel({
    super.key,
    this.size = 480,
    this.opacity = 1,
    this.color = Colors.white,
    this.showRashis = false,
    this.animate = true,
  });

  final double size;
  final double opacity;
  final Color color;
  final bool showRashis;
  final bool animate;

  @override
  State<CosmicWheel> createState() => _CosmicWheelState();
}

class _CosmicWheelState extends LoopingAnimationState<CosmicWheel> {
  @override
  Duration get period => const Duration(seconds: 120);

  @override
  bool get animates => widget.animate;

  late final List<TextPainter> _numbers = List.generate(
    12,
    (i) => TextPainter(
      text: TextSpan(
        text: '${i + 1}',
        style: AppText.body(
          widget.size < 300 ? 9 : 11,
          color: widget.color.withValues(alpha: 0.4),
          weight: FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(),
  );

  late final List<TextPainter> _rashis = [
    for (final name in rashiNames)
      TextPainter(
        text: TextSpan(
          text: name,
          style: AppText.body(
            9.5,
            color: AppColors.warmAccent.withValues(alpha: 0.75),
            weight: FontWeight.w600,
            letterSpacing: 2.2,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
  ];

  @override
  Widget build(BuildContext context) {
    // Opacity is applied through the colours, not an Opacity layer.
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        isComplex: true,
        painter: _CosmicWheelPainter(
          controller,
          widget.color,
          widget.opacity,
          _numbers,
          widget.showRashis ? _rashis : null,
        ),
      ),
    );
  }
}

class _CosmicWheelPainter extends CustomPainter {
  _CosmicWheelPainter(
    this.animation,
    this.color,
    this.opacity,
    this.numbers,
    this.rashis,
  ) : super(repaint: animation);

  final ValueListenable<double> animation;
  final Color color;
  final double opacity;
  final List<TextPainter> numbers;
  final List<TextPainter>? rashis;

  Size? _cachedFor;
  late Paint _glow, _core;

  Paint _ring(double alpha, [double width = 1]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = color.withValues(alpha: alpha * opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final turn = animation.value * 2 * pi;
    final warm = AppColors.warmAccent;

    if (_cachedFor != size) {
      _cachedFor = size;
      _glow = Paint()..shader = _radialGlow(c, r, warm, 0.16 * opacity);
      _core = Paint()..shader = _radialGlow(c, r * 0.12, warm, 0.9 * opacity);
    }

    canvas.drawCircle(c, r, _glow);
    canvas.drawCircle(c, r * 0.99, _ring(0.10));
    canvas.drawCircle(c, r * 0.90, _ring(0.22));

    final dimText = opacity < 1;
    if (rashis != null) {
      for (var i = 0; i < 12; i++) {
        final a = turn + (i + 0.5) * pi / 6;
        final tp = rashis![i];
        canvas.save();
        canvas.translate(c.dx + cos(a) * r * 0.945, c.dy + sin(a) * r * 0.945);
        canvas.rotate(a + pi / 2);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
        final sep = turn + i * pi / 6;
        final dir = Offset(cos(sep), sin(sep));
        canvas.drawLine(c + dir * r * 0.90, c + dir * r * 0.99, _ring(0.2));
      }
    }

    // 27 nakshatra ticks — rotate clockwise.
    final minorTick = Paint()
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.3 * opacity);
    final majorTick = Paint()
      ..strokeWidth = 1.6
      ..color = warm.withValues(alpha: 0.7 * opacity);
    final dotMajor = Paint()..color = color.withValues(alpha: 0.55 * opacity);
    final dotMinor = Paint()..color = color.withValues(alpha: 0.25 * opacity);
    for (var i = 0; i < 27; i++) {
      final a = turn + i * 2 * pi / 27;
      final dir = Offset(cos(a), sin(a));
      final major = i % 3 == 0;
      canvas.drawLine(
        c + dir * r * (major ? 0.83 : 0.86),
        c + dir * r * 0.90,
        major ? majorTick : minorTick,
      );
      if (rashis == null) {
        canvas.drawCircle(
          c + dir * r * 0.935,
          major ? 2.2 : 1.3,
          major ? dotMajor : dotMinor,
        );
      }
    }

    // 12 houses — rotate the other way, slower.
    final houseTurn = -turn * 0.5;
    final houseLine = _ring(0.16);
    canvas.drawCircle(c, r * 0.74, houseLine);
    canvas.drawCircle(c, r * 0.58, _ring(0.12));
    for (var i = 0; i < 12; i++) {
      final a = houseTurn + i * pi / 6;
      final dir = Offset(cos(a), sin(a));
      canvas.drawLine(c + dir * r * 0.58, c + dir * r * 0.74, houseLine);
      if (!dimText) {
        final mid = houseTurn + (i + 0.5) * pi / 6;
        final tp = numbers[i];
        final pos = c + Offset(cos(mid), sin(mid)) * r * 0.66;
        tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Faint twelve-point star connecting the houses.
    final star = Path();
    for (var i = 0; i <= 12; i++) {
      final a = houseTurn + (i * 5 % 12) * pi / 6;
      final p = c + Offset(cos(a), sin(a)) * r * 0.58;
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(star, _ring(0.07));

    // Dashed inner ring, as one path.
    final dashes = Path();
    final dashRect = Rect.fromCircle(center: c, radius: r * 0.47);
    for (var i = 0; i < 60; i += 2) {
      dashes.addArc(dashRect, turn * 2 + i * 2 * pi / 60, 2 * pi / 60);
    }
    canvas.drawPath(dashes, _ring(0.18));

    // Planet orbits — integer speeds keep the loop seamless.
    const orbits = [
      (radius: 0.39, speed: 3, size: 5.0, warm: true),
      (radius: 0.30, speed: -5, size: 4.0, warm: false),
      (radius: 0.21, speed: 8, size: 3.4, warm: true),
    ];
    final orbitLine = _ring(0.09);
    for (final o in orbits) {
      canvas.drawCircle(c, r * o.radius, orbitLine);
      final a = turn * o.speed + o.radius * 10;
      final p = c + Offset(cos(a), sin(a)) * r * o.radius;
      final pc = (o.warm ? warm : color).withValues(alpha: opacity);
      _halo(canvas, p, o.size, pc);
      canvas.drawCircle(p, o.size, Paint()..color = pc);
    }

    canvas.drawCircle(c, r * 0.12, _core);
    canvas.drawCircle(
      c,
      r * 0.035,
      Paint()..color = const Color(0xFFF3E3C3).withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_CosmicWheelPainter old) => false;
}

// ------------------------------------------------------------ YANTRA

/// A slowly turning lotus mandala with interlocking triangles — used behind
/// the Spiritual Poojas panel.
class YantraMandala extends StatefulWidget {
  const YantraMandala({super.key, this.size = 420, this.opacity = 1});
  final double size;
  final double opacity;

  @override
  State<YantraMandala> createState() => _YantraMandalaState();
}

class _YantraMandalaState extends LoopingAnimationState<YantraMandala> {
  @override
  Duration get period => const Duration(seconds: 100);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(widget.size),
      isComplex: true,
      painter: _YantraPainter(controller, widget.opacity),
    ),
  );
}

class _YantraPainter extends CustomPainter {
  _YantraPainter(this.animation, this.opacity) : super(repaint: animation);
  final ValueListenable<double> animation;
  final double opacity;

  Size? _cachedFor;
  late Paint _center;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final turn = animation.value * 2 * pi;
    final gold = AppColors.warmAccent;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = gold.withValues(alpha: 0.55 * opacity);
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gold.withValues(alpha: 0.3 * opacity);
    if (_cachedFor != size) {
      _cachedFor = size;
      _center = Paint()..shader = _radialGlow(c, r * 0.12, gold, 0.6 * opacity);
    }

    canvas.drawCircle(c, r * 0.98, faint);
    canvas.drawCircle(c, r * 0.94, faint);

    void lotus(int petals, double base, double tip, double rot) {
      final half = pi / petals;
      final path = Path();
      for (var i = 0; i < petals; i++) {
        final a = rot + i * 2 * pi / petals;
        final b1 = c + Offset(cos(a - half), sin(a - half)) * r * base;
        final b2 = c + Offset(cos(a + half), sin(a + half)) * r * base;
        final tipP = c + Offset(cos(a), sin(a)) * r * tip;
        final mid = (base + tip) / 2 + 0.04;
        final c1 =
            c + Offset(cos(a - half * 0.7), sin(a - half * 0.7)) * r * mid;
        final c2 =
            c + Offset(cos(a + half * 0.7), sin(a + half * 0.7)) * r * mid;
        path
          ..moveTo(b1.dx, b1.dy)
          ..quadraticBezierTo(c1.dx, c1.dy, tipP.dx, tipP.dy)
          ..quadraticBezierTo(c2.dx, c2.dy, b2.dx, b2.dy);
      }
      canvas.drawPath(path, stroke);
      canvas.drawCircle(c, r * base, faint);
    }

    lotus(16, 0.64, 0.90, turn);
    lotus(8, 0.42, 0.62, -turn);

    final triangles = Path();
    void triangle(double rot, double radius) {
      for (var i = 0; i < 3; i++) {
        final a = rot + i * 2 * pi / 3;
        final p = c + Offset(cos(a), sin(a)) * r * radius;
        i == 0 ? triangles.moveTo(p.dx, p.dy) : triangles.lineTo(p.dx, p.dy);
      }
      triangles.close();
    }

    final tri = turn * 0.5;
    triangle(-pi / 2 + tri, 0.40);
    triangle(pi / 2 + tri, 0.40);
    triangle(-pi / 2 - tri, 0.28);
    triangle(pi / 2 - tri, 0.28);
    canvas.drawPath(triangles, stroke);

    canvas.drawCircle(c, r * 0.12, _center);
    canvas.drawCircle(
      c,
      r * 0.03,
      Paint()..color = gold.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_YantraPainter old) => false;
}

// ---------------------------------------------------------- NAVAGRAHA

typedef _Graha = ({
  String name,
  double orbit,
  int speed,
  double offset,
  double size,
  bool warm,
});

/// The nine planets of Vedic astrology orbiting Surya. Rahu and Ketu, the
/// lunar nodes, always sit exactly opposite each other.
class NavagrahaOrbit extends StatefulWidget {
  const NavagrahaOrbit({super.key, this.size = 400});
  final double size;

  @override
  State<NavagrahaOrbit> createState() => _NavagrahaOrbitState();
}

class _NavagrahaOrbitState extends LoopingAnimationState<NavagrahaOrbit> {
  @override
  Duration get period => const Duration(seconds: 150);

  static const List<_Graha> _grahas = [
    (
      name: 'CHANDRA',
      orbit: 0.26,
      speed: 6,
      offset: 0.0,
      size: 4.0,
      warm: false,
    ),
    (name: 'BUDHA', orbit: 0.26, speed: 6, offset: pi, size: 3.2, warm: false),
    (
      name: 'SHUKRA',
      orbit: 0.43,
      speed: -4,
      offset: 1.0,
      size: 4.4,
      warm: false,
    ),
    (
      name: 'MANGALA',
      orbit: 0.43,
      speed: -4,
      offset: 1.0 + pi,
      size: 3.8,
      warm: true,
    ),
    (name: 'GURU', orbit: 0.61, speed: 2, offset: 2.2, size: 5.6, warm: true),
    (
      name: 'SHANI',
      orbit: 0.61,
      speed: 2,
      offset: 2.2 + pi,
      size: 5.0,
      warm: false,
    ),
    (name: 'RAHU', orbit: 0.80, speed: -1, offset: 0.6, size: 3.6, warm: false),
    (
      name: 'KETU',
      orbit: 0.80,
      speed: -1,
      offset: 0.6 + pi,
      size: 3.6,
      warm: false,
    ),
  ];

  late final Map<String, TextPainter> _labels = {
    for (final name in [for (final g in _grahas) g.name, 'SURYA'])
      name: TextPainter(
        text: TextSpan(
          text: name,
          style: AppText.body(
            widget.size < 340 ? 8.5 : 9.5,
            color: name == 'SURYA'
                ? AppColors.warmAccent
                : Colors.white.withValues(alpha: 0.62),
            weight: FontWeight.w600,
            letterSpacing: 1.8,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
  };

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(widget.size),
      isComplex: true,
      painter: _NavagrahaPainter(controller, _grahas, _labels),
    ),
  );
}

class _NavagrahaPainter extends CustomPainter {
  _NavagrahaPainter(this.animation, this.grahas, this.labels)
    : super(repaint: animation);

  final ValueListenable<double> animation;
  final List<_Graha> grahas;
  final Map<String, TextPainter> labels;

  Size? _cachedFor;
  late Paint _sun;
  late Path _dashedNodes;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.92;
    final turn = animation.value * 2 * pi;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.12);

    if (_cachedFor != size) {
      _cachedFor = size;
      _sun = Paint()
        ..shader = _radialGlow(c, r * 0.2, AppColors.warmAccent, 0.75);
      _dashedNodes = Path();
      final rect = Rect.fromCircle(center: c, radius: r * 0.80);
      for (var i = 0; i < 90; i += 2) {
        _dashedNodes.addArc(rect, i * 2 * pi / 90, 2 * pi / 90);
      }
    }

    for (final o in const [0.26, 0.43, 0.61]) {
      canvas.drawCircle(c, r * o, orbitPaint);
    }
    canvas.drawPath(_dashedNodes, orbitPaint);

    canvas.drawCircle(c, r * 0.2, _sun);
    canvas.drawCircle(c, r * 0.055, Paint()..color = const Color(0xFFF3E3C3));
    final surya = labels['SURYA']!;
    surya.paint(canvas, c + Offset(-surya.width / 2, r * 0.09));

    // Line joining Rahu and Ketu.
    final node = -turn + 0.6;
    final nodeDir = Offset(cos(node), sin(node)) * r * 0.8;
    canvas.drawLine(
      c + nodeDir,
      c - nodeDir,
      Paint()
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.08),
    );

    for (final g in grahas) {
      final a = turn * g.speed + g.offset;
      final p = c + Offset(cos(a), sin(a)) * r * g.orbit;
      final color = g.warm ? AppColors.warmAccent : Colors.white;
      _halo(canvas, p, g.size, color);
      canvas.drawCircle(p, g.size, Paint()..color = color);
      final tp = labels[g.name]!;
      tp.paint(canvas, p + Offset(-tp.width / 2, g.size + 6));
    }
  }

  @override
  bool shouldRepaint(_NavagrahaPainter old) => false;
}

// ------------------------------------------------------------- ROTATING RING

/// Dashed ring that slowly rotates — used around the astrologer portrait.
class RotatingRing extends StatefulWidget {
  const RotatingRing({super.key, required this.size});
  final double size;

  @override
  State<RotatingRing> createState() => _RotatingRingState();
}

class _RotatingRingState extends LoopingAnimationState<RotatingRing> {
  @override
  Duration get period => const Duration(seconds: 50);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(widget.size),
      painter: _RingPainter(controller),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.animation) : super(repaint: animation);
  final ValueListenable<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final turn = animation.value * 2 * pi;
    final dashes = Path();
    final rect = Rect.fromCircle(center: c, radius: r - 2);
    for (var i = 0; i < 72; i += 2) {
      dashes.addArc(rect, turn + i * 2 * pi / 72, 2 * pi / 72);
    }
    canvas.drawPath(
      dashes,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      c,
      r * 0.9,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.10),
    );
    for (final (offset, warm) in [(0.0, true), (pi, false)]) {
      final a = -turn * 2 + offset;
      final p = c + Offset(cos(a), sin(a)) * (r - 2);
      final color = warm ? AppColors.warmAccent : Colors.white;
      _halo(canvas, p, 4, color);
      canvas.drawCircle(p, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}
