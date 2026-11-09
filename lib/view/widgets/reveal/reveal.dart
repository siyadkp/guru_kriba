import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';

/// Fades and slides its child in the first time it scrolls into view.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.12),
    this.duration = const Duration(milliseconds: 700),
  });

  final Widget child;
  final Duration delay;

  /// Starting offset as a fraction of the child's size.
  final Offset offset;
  final Duration duration;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with ViewportAware<Reveal> {
  bool _visible = false;
  Timer? _timer;

  // Start once the widget is a little way onto the screen.
  @override
  double get viewportMargin => -40;

  @override
  void onViewportChanged(bool visible) {
    if (!visible) return;
    stopWatchingViewport();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.offset,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
