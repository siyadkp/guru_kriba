import 'dart:async';

import 'package:flutter/widgets.dart';

/// One shared, low-rate clock for every decorative looping animation.
///
/// On the web every rendered frame redraws the whole visible page, and an
/// active Flutter ticker requests a frame at the display rate (60 fps or
/// more) for as long as it runs. Driving all decoration from a single
/// 30 fps timer halves that work while idle and leaves the main thread
/// free for smooth scrolling. The timer only runs while something visible
/// is listening.
class FrameClock {
  FrameClock._();
  static final FrameClock instance = FrameClock._();

  static const Duration interval = Duration(milliseconds: 33);

  final Set<VoidCallback> _listeners = {};
  final Stopwatch _watch = Stopwatch();
  Timer? _timer;

  /// Time since the clock first started; keeps counting across pauses.
  Duration get elapsed => _watch.elapsed;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    if (_timer == null) {
      _watch.start();
      _timer = Timer.periodic(interval, (_) {
        for (final l in List.of(_listeners)) {
          l();
        }
      });
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _timer?.cancel();
      _timer = null;
      _watch.stop();
    }
  }
}

/// Whether the visitor is scrolling right now. Hover effects wait while
/// it is true, so cards sliding under a still mouse don't start
/// animations mid-scroll.
class PageScroll {
  static final ValueNotifier<bool> isScrolling = ValueNotifier(false);
  static Timer? _settle;

  /// Called on every scroll update.
  static void ping() {
    if (!isScrolling.value) isScrolling.value = true;
    _settle?.cancel();
    _settle = Timer(const Duration(milliseconds: 180), () {
      isScrolling.value = false;
    });
  }
}

/// Gives widgets on the single page access to the page's scroll position,
/// so they can tell cheaply whether they are on screen.
class ViewportScope extends InheritedWidget {
  const ViewportScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final ScrollController controller;

  static ScrollController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ViewportScope>()?.controller;

  @override
  bool updateShouldNotify(ViewportScope oldWidget) =>
      oldWidget.controller != controller;
}

/// Tells a [State] when its widget enters or leaves the screen.
///
/// The widget's position on the page is measured once and then reused,
/// so each scroll update is just a comparison of two numbers. It is
/// re-measured every half second (layout above can change, e.g. an FAQ
/// opening) and when the window resizes. Without a [ViewportScope] above
/// it, the widget counts as always visible.
mixin ViewportAware<T extends StatefulWidget> on State<T> {
  ScrollController? _scroll;
  bool? _inViewport;
  bool _watching = true;
  double _screenHeight = 0;
  double? _pageTop;
  double _height = 0;
  final Stopwatch _sinceMeasured = Stopwatch();

  bool get inViewport => _inViewport ?? false;

  /// Distance beyond the screen edges that still counts as visible.
  /// Negative values require the widget to be that far inside the screen.
  double get viewportMargin => 0;

  void onViewportChanged(bool visible);

  /// Stops checking — for one-shot uses such as reveal-on-scroll.
  void stopWatchingViewport() {
    _watching = false;
    _scroll?.removeListener(checkViewport);
    _scroll = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenHeight = MediaQuery.sizeOf(context).height;
    _pageTop = null;
    if (!_watching) return;
    final scroll = ViewportScope.maybeOf(context);
    if (scroll != _scroll) {
      _scroll?.removeListener(checkViewport);
      _scroll = scroll;
      _scroll?.addListener(checkViewport);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => checkViewport());
  }

  bool _measure() {
    final box = context.findRenderObject();
    final scroll = _scroll;
    if (box is! RenderBox || !box.attached || !box.hasSize || scroll == null) {
      return false;
    }
    if (!scroll.hasClients) return false;
    _pageTop = box.localToGlobal(Offset.zero).dy + scroll.offset;
    _height = box.size.height;
    _sinceMeasured
      ..reset()
      ..start();
    return true;
  }

  void checkViewport() {
    if (!mounted || !_watching) return;
    bool visible;
    final scroll = _scroll;
    if (scroll == null) {
      visible = true;
    } else {
      if ((_pageTop == null || _sinceMeasured.elapsedMilliseconds > 500) &&
          !_measure()) {
        return;
      }
      final top = _pageTop! - scroll.offset;
      final margin = viewportMargin;
      visible = top < _screenHeight + margin && top + _height > -margin;
    }
    if (visible != _inViewport) {
      _inViewport = visible;
      onViewportChanged(visible);
    }
  }

  @override
  void dispose() {
    _scroll?.removeListener(checkViewport);
    super.dispose();
  }
}
