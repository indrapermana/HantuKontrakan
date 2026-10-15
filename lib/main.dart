import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'services/audio_service.dart';
import 'services/error_reporting_service.dart';
import 'services/game_feedback_service.dart';
import 'services/privacy_consent_service.dart';
import 'services/rewarded_ad_service.dart';
import 'services/save_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final privacyConsent = GoogleUmpPrivacyConsentService();
  final errorReporting = ConsentAwareErrorReportingService();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      errorReporting.record(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: 'flutter_framework',
        fatal: true,
      ),
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(
      errorReporting.record(
        error,
        stackTrace,
        reason: 'platform_dispatcher',
        fatal: true,
      ),
    );
    return false;
  };
  runApp(
    HantuKontrakanApp(
      saveService: SharedPreferencesSaveService(),
      audioService: AudioplayersAudioService(),
      feedbackService: const FlutterGameFeedbackService(),
      errorReportingService: errorReporting,
      privacyConsentService: privacyConsent,
      rewardedAdService: GoogleTestRewardedAdService(
        privacyConsent: privacyConsent,
      ),
    ),
  );
}
