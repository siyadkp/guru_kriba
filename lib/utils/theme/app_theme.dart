import 'package:flutter/material.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = base.textTheme.apply(fontFamily: AppText.bodyFont);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.charcoal,
        onPrimary: Colors.white,
        secondary: AppColors.slate,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.charcoal,
        error: Color(0xFFB4413C),
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.charcoal,
        displayColor: AppColors.charcoal,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.charcoal,
        selectionColor: Color(0x334A5568),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppText.body(14, color: AppColors.mediumGray),
        floatingLabelStyle: AppText.body(
          14,
          color: AppColors.charcoal,
          weight: FontWeight.w600,
        ),
        hintStyle: AppText.body(14, color: AppColors.mediumGray),
        prefixIconColor: AppColors.mediumGray,
        border: border(AppColors.hairline),
        enabledBorder: border(AppColors.hairline),
        focusedBorder: border(AppColors.slate, 1.5),
        errorBorder: border(const Color(0xFFB4413C)),
        focusedErrorBorder: border(const Color(0xFFB4413C), 1.5),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: AppText.body(14, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppText.body(12.5, color: Colors.white, height: 1.3),
      ),
    );
  }
}
