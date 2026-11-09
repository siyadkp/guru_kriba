import 'package:flutter/material.dart';
import 'package:guru_kripa/routes/app_routes.dart';
import 'package:guru_kripa/utils/theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:
          'Guru Kripa Astro Science | KP Astrology & Spiritual Pooja Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: PageRouter.generateRoute,
      initialRoute: RoutePaths.home,
    );
  }
}
