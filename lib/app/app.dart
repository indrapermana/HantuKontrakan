import 'dart:async';

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

class _HantuKontrakanAppState extends State<HantuKontrakanApp>
    with WidgetsBindingObserver {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = GameController(saveService: widget.saveService)..initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.resumeFromOffline());
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(controller.pauseForOffline());
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final router = AppRouter(controller: controller);
        final savedLanguage = controller.isReady
            ? controller.state.languageCode
            : null;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: AppTheme.dark,
          locale:
              widget.locale ??
              (savedLanguage == null ? null : Locale(savedLanguage)),
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
      },
    );
  }
}
