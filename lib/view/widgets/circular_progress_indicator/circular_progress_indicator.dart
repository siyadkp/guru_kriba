import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  const CircularProgressIndicatorWidget({
    super.key,
    this.colors = AppColors.primaryColor,
  });
  final Color colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          CircularProgressIndicator(color: colors, strokeWidth: 2),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
