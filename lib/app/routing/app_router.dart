import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../features/home/home_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
}

class AppRouter {
  const AppRouter({required this.controller});

  final GameController controller;

  Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => HomeScreen(controller: controller),
      ),
      _ => throw FlutterError('Unknown route: ${settings.name}'),
    };
  }
}
