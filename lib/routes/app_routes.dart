import 'package:flutter/material.dart';
import 'package:guru_kripa/view/home_page/home_page.dart';

class RoutePaths {
  /// The website is a single page.
  static const home = '/';
}

class PageRouter {
  static Route<Object> generateRoute(RouteSettings settings) {
    // Every URL shows the single page, so shared or mistyped links still work.
    return MaterialPageRoute(
      settings: const RouteSettings(name: RoutePaths.home),
      builder: (_) => const HomePage(),
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return navigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> push<T extends Object?>(Route<T> route) async {
    return navigatorKey.currentState?.push<T>(route);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  Future<bool?> maybePop<T extends Object?>([T? result]) async {
    return navigatorKey.currentState?.maybePop<T>(result);
  }

  bool canPop() => navigatorKey.currentState?.canPop() ?? false;

  void goBack<T extends Object?>({T? result}) {
    navigatorKey.currentState?.pop<T>(result);
  }
}
