import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';

/// Typography: Poppins for headings, Inter for body copy.
///
/// Both fonts are bundled with the app (see `fonts:` in pubspec.yaml), so
/// they are ready before the first frame and need no network requests.
class AppText {
  static const String headingFont = 'Poppins';
  static const String bodyFont = 'Inter';

  static TextStyle heading(
    double size, {
    Color color = AppColors.charcoal,
    FontWeight weight = FontWeight.w600,
    double height = 1.2,
    double letterSpacing = -0.2,
  }) => TextStyle(
    fontFamily: headingFont,
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle body(
    double size, {
    Color color = AppColors.slate,
    FontWeight weight = FontWeight.w400,
    double height = 1.7,
    double letterSpacing = 0,
    FontStyle? fontStyle,
  }) => TextStyle(
    fontFamily: bodyFont,
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
  );

  /// Small upper-case label used above section titles and on buttons.
  static TextStyle eyebrow({
    Color color = AppColors.slate,
    double size = 12.5,
  }) => body(
    size,
    color: color,
    weight: FontWeight.w600,
    letterSpacing: 3,
    height: 1.4,
  );
}
