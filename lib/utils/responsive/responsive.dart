import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double tablet = 700;
  static const double desktop = 1100;

  /// Width at which the full navigation menu fits in the header.
  static const double fullNav = 1320;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isMobile => screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;
  bool get showFullNav => screenWidth >= Breakpoints.fullNav;

  /// Horizontal page padding.
  double get gutter => isMobile ? 20 : (isDesktop ? 48 : 36);

  /// Vertical padding of each page section.
  double get sectionPadding => isMobile ? 72 : 112;

  double get headerHeight => isMobile ? 64 : 76;

  /// Picks a value for mobile / tablet / desktop.
  T responsive<T>(T mobile, T tablet, T desktop) =>
      isMobile ? mobile : (isDesktop ? desktop : tablet);
}

/// Centers content and limits it to a comfortable reading width.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = context.gutter;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );
  }
}

/// Lays children out in equal-height rows of [columns] items.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = 24,
    this.centerLastRow = false,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;
  final bool centerLastRow;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = columns.clamp(1, children.length);
        final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += cols) {
          final end = (i + cols).clamp(0, children.length);
          final items = children.sublist(i, end);
          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: centerLastRow
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < items.length; j++) ...[
                    if (j > 0) SizedBox(width: spacing),
                    SizedBox(width: itemWidth, child: items[j]),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
