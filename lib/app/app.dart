import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../application/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../services/save_service.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class HantuKontrakanApp extends StatefulWidget {
  const HantuKontrakanApp({required this.saveService, this.locale, super.key});

  final SaveService saveService;
  final Locale? locale;

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
  Widget build(BuildContext context) {
    final router = AppRouter(controller: controller);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.dark,
      locale: widget.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.home,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
