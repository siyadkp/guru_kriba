import 'package:flutter/material.dart';

/// Gray monochromatic palette from the website brief, plus one muted warm
/// accent for the "subtle warm accent lighting" the brief asks for.
class AppColors {
  static const Color charcoal = Color(0xFF1A1D20);
  static const Color charcoalDeep = Color(0xFF121417);
  static const Color charcoalSoft = Color(0xFF24282D);
  static const Color slate = Color(0xFF4A5568);
  static const Color mediumGray = Color(0xFF718096);
  static const Color platinum = Color(0xFFEDF2F7);
  static const Color offWhite = Color(0xFFF7FAFC);
  static const Color hairline = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  static const Color warmAccent = Color(0xFFC9A46A);
  static const Color whatsapp = Color(0xFF25D366);

  // Names used by the shared widgets.
  static const Color primaryColor = charcoal;
  static const Color borderColor = Colors.white;
  static const Color secondColor = slate;
}
