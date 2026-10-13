import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/analytics_service.dart';

void main() {
  test('catalog uses the planned stable wire names', () {
    expect(GameplayAnalyticsEventName.values.map((event) => event.wireName), [
      'app_open',
      'tutorial_started',
      'tutorial_completed',
      'ghost_placed',
      'room_upgraded',
      'room_unlocked',
      'rent_collected',
      'incident_started',
      'incident_choice_selected',
      'incident_resolved',
      'offline_earnings_claimed',
      'ad_offer_shown',
      'ad_started',
      'ad_reward_earned',
      'ad_failed',
      'purchase_started',
      'purchase_completed',
    ]);
  });

  test('payload schema rejects unapproved and complex personal data', () {
    expect(
      () => GameplayAnalyticsEvent(GameplayAnalyticsEventName.appOpen, {
        'email': 'someone@example.com',
      }),
      throwsArgumentError,
    );
    expect(
      () => GameplayAnalyticsEvent(GameplayAnalyticsEventName.ghostPlaced, {
        'ghost_kind': ['pocong'],
      }),
      throwsArgumentError,
    );
  });
}
