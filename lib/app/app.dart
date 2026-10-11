import 'package:flutter/material.dart';

import '../application/game_controller.dart';
import '../features/home/home_screen.dart';
import '../services/save_service.dart';

class HantuKontrakanApp extends StatefulWidget {
  const HantuKontrakanApp({required this.saveService, super.key});

  final SaveService saveService;

  @override
  State<HantuKontrakanApp> createState() => _HantuKontrakanAppState();
}

class _HantuKontrakanAppState extends State<HantuKontrakanApp> {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(saveService: widget.saveService)..initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hantu Kontrakan',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7357B7),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF100E26),
      useMaterial3: true,
    ),
    home: HomeScreen(controller: controller),
  );
}
