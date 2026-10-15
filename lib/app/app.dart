import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../application/game_controller.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_service.dart';
import '../services/error_reporting_service.dart';
import '../services/game_feedback_service.dart';
import '../services/privacy_consent_service.dart';
import '../services/rewarded_ad_service.dart';
import '../services/save_service.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class HantuKontrakanApp extends StatefulWidget {
  const HantuKontrakanApp({
    required this.saveService,
    this.audioService,
    this.errorReportingService,
    this.privacyConsentService,
    this.rewardedAdService,
    this.feedbackService,
    this.locale,
    super.key,
  });

  final SaveService saveService;
  final AudioService? audioService;
  final ErrorReportingService? errorReportingService;
  final PrivacyConsentService? privacyConsentService;
  final RewardedAdService? rewardedAdService;
  final GameFeedbackService? feedbackService;
  final Locale? locale;

  @override
  State<HantuKontrakanApp> createState() => _HantuKontrakanAppState();
}

class _HantuKontrakanAppState extends State<HantuKontrakanApp>
    with WidgetsBindingObserver {
  late final GameController controller;
  Timer? _simulationTimer;
  bool _simulationActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = GameController(
      saveService: widget.saveService,
      audioService: widget.audioService ?? const NoopAudioService(),
      errorReportingService:
          widget.errorReportingService ?? const NoopErrorReportingService(),
      privacyConsentService:
          widget.privacyConsentService ??
          const UnavailablePrivacyConsentService(),
      rewardedAdService:
          widget.rewardedAdService ?? const UnavailableRewardedAdService(),
      feedbackService:
          widget.feedbackService ?? const NoopGameFeedbackService(),
    );
    unawaited(_initializeController());
  }

  Future<void> _initializeController() async {
    await controller.initialize();
    if (!mounted) return;
    _simulationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_simulationActive && controller.isReady) {
        unawaited(controller.advanceSimulation(10));
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _simulationActive = true;
        unawaited(controller.resumeFromOffline());
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _simulationActive = false;
        unawaited(controller.pauseForOffline());
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
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
