enum GameplayAnalyticsEventName {
  appOpen('app_open'),
  tutorialStarted('tutorial_started'),
  tutorialCompleted('tutorial_completed'),
  ghostPlaced('ghost_placed'),
  roomUpgraded('room_upgraded'),
  roomUnlocked('room_unlocked'),
  rentCollected('rent_collected'),
  incidentStarted('incident_started'),
  incidentChoiceSelected('incident_choice_selected'),
  incidentResolved('incident_resolved'),
  offlineEarningsClaimed('offline_earnings_claimed'),
  adOfferShown('ad_offer_shown'),
  adStarted('ad_started'),
  adRewardEarned('ad_reward_earned'),
  adFailed('ad_failed'),
  purchaseStarted('purchase_started'),
  purchaseCompleted('purchase_completed');

  const GameplayAnalyticsEventName(this.wireName);

  final String wireName;
}

class GameplayAnalyticsEvent {
  GameplayAnalyticsEvent(this.name, [Map<String, Object> parameters = const {}])
    : parameters = Map.unmodifiable(parameters) {
    final allowed = _allowedParameters[name]!;
    if (parameters.length != allowed.length ||
        !parameters.keys.every(allowed.contains) ||
        parameters.values.any(
          (value) => value is! String && value is! int && value is! bool,
        )) {
      throw ArgumentError('Analytics payload is outside the approved schema.');
    }
  }

  final GameplayAnalyticsEventName name;
  final Map<String, Object> parameters;

  static const Map<GameplayAnalyticsEventName, Set<String>>
  _allowedParameters = {
    GameplayAnalyticsEventName.appOpen: {},
    GameplayAnalyticsEventName.tutorialStarted: {},
    GameplayAnalyticsEventName.tutorialCompleted: {},
    GameplayAnalyticsEventName.ghostPlaced: {'ghost_kind', 'room_id'},
    GameplayAnalyticsEventName.roomUpgraded: {'room_id', 'attribute', 'level'},
    GameplayAnalyticsEventName.roomUnlocked: {'room_id', 'cost'},
    GameplayAnalyticsEventName.rentCollected: {'coins'},
    GameplayAnalyticsEventName.incidentStarted: {'incident_id', 'scripted'},
    GameplayAnalyticsEventName.incidentChoiceSelected: {
      'incident_id',
      'choice_id',
    },
    GameplayAnalyticsEventName.incidentResolved: {'incident_id', 'choice_id'},
    GameplayAnalyticsEventName.offlineEarningsClaimed: {'coins'},
    GameplayAnalyticsEventName.adOfferShown: {'placement'},
    GameplayAnalyticsEventName.adStarted: {'placement'},
    GameplayAnalyticsEventName.adRewardEarned: {'placement', 'coins'},
    GameplayAnalyticsEventName.adFailed: {'placement', 'reason_code'},
    GameplayAnalyticsEventName.purchaseStarted: {'product_id'},
    GameplayAnalyticsEventName.purchaseCompleted: {'product_id'},
  };
}

abstract interface class AnalyticsService {
  Future<void> record(GameplayAnalyticsEvent event);
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> record(GameplayAnalyticsEvent event) async {}
}
