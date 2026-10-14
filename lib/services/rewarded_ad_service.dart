import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RewardedAdOutcome { earned, dismissed, unavailable, failed }

abstract interface class RewardedAdService {
  Future<RewardedAdOutcome> showRewardedAd({
    required Future<void> Function() onRewardEarned,
  });
}

class UnavailableRewardedAdService implements RewardedAdService {
  const UnavailableRewardedAdService();

  @override
  Future<RewardedAdOutcome> showRewardedAd({
    required Future<void> Function() onRewardEarned,
  }) async => RewardedAdOutcome.unavailable;
}

class GoogleTestRewardedAdService implements RewardedAdService {
  static const String androidTestUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosTestUnitId = 'ca-app-pub-3940256099942544/1712485313';

  bool _initialized = false;

  @override
  Future<RewardedAdOutcome> showRewardedAd({
    required Future<void> Function() onRewardEarned,
  }) async {
    final adUnitId = switch (defaultTargetPlatform) {
      TargetPlatform.android => androidTestUnitId,
      TargetPlatform.iOS => iosTestUnitId,
      _ => null,
    };
    if (adUnitId == null) return RewardedAdOutcome.unavailable;

    try {
      if (!_initialized) {
        await MobileAds.instance.initialize();
        _initialized = true;
      }
      final completer = Completer<RewardedAdOutcome>();
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdFailedToLoad: (_) {
            if (!completer.isCompleted) {
              completer.complete(RewardedAdOutcome.unavailable);
            }
          },
          onAdLoaded: (ad) {
            var earned = false;
            Future<void> rewardCallbacks = Future<void>.value();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, _) {
                ad.dispose();
                if (!completer.isCompleted) {
                  completer.complete(RewardedAdOutcome.failed);
                }
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                rewardCallbacks.whenComplete(() {
                  if (!completer.isCompleted) {
                    completer.complete(
                      earned
                          ? RewardedAdOutcome.earned
                          : RewardedAdOutcome.dismissed,
                    );
                  }
                });
              },
            );
            ad.show(
              onUserEarnedReward: (_, _) {
                earned = true;
                rewardCallbacks = rewardCallbacks.then((_) => onRewardEarned());
              },
            );
          },
        ),
      );
      return completer.future;
    } on Object {
      return RewardedAdOutcome.failed;
    }
  }
}
