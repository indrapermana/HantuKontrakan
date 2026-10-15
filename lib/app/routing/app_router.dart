import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../features/home/home_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
}

class AppRouter {
  const AppRouter({required this.controller, this.showDebugTools = false});

  final GameController controller;
  final bool showDebugTools;

  Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            HomeScreen(controller: controller, showDebugTools: showDebugTools),
      ),
      _ => throw FlutterError('Unknown route: ${settings.name}'),
    };
  }
}
