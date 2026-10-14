import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract interface class PrivacyConsentService {
  Future<void> initialize();
  Future<bool> canRequestAds();
  Future<bool> isPrivacyOptionsRequired();
  Future<void> showPrivacyOptions();
}

class UnavailablePrivacyConsentService implements PrivacyConsentService {
  const UnavailablePrivacyConsentService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> canRequestAds() async => false;

  @override
  Future<bool> isPrivacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}

class GoogleUmpPrivacyConsentService implements PrivacyConsentService {
  Future<void>? _initialization;

  @override
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } finally {
            if (!completer.isCompleted) completer.complete();
          }
        },
        (_) {
          if (!completer.isCompleted) completer.complete();
        },
      );
    } on Object {
      if (!completer.isCompleted) completer.complete();
    }
    await completer.future;
  }

  @override
  Future<bool> canRequestAds() async {
    await initialize();
    return ConsentInformation.instance.canRequestAds();
  }

  @override
  Future<bool> isPrivacyOptionsRequired() async {
    await initialize();
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> showPrivacyOptions() async {
    await initialize();
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) => completer.complete());
    await completer.future;
  }
}
