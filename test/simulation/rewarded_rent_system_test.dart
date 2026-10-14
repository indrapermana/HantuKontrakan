import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/rewarded_rent_system.dart';

void main() {
  test('base and snapshotted bonus commit separately and exactly once', () {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 2750000);

    final begun = GameRules.beginRewardedRentClaim(
      initial,
      'reward-1',
      '2026-10-14',
    );
    final granted = GameRules.grantRewardedRentBonus(begun, 'reward-1');
    final duplicate = GameRules.grantRewardedRentBonus(granted, 'reward-1');

    expect(begun.walletCoins, 202);
    expect(begun.pendingRentMicrocoins, 750000);
    expect(begun.completedRentClaimIds, {'reward-1'});
    expect(begun.pendingRewardedRentClaim?.bonusCoins, 2);
    expect(granted.walletCoins, 204);
    expect(granted.pendingRewardedRentClaim, isNull);
    expect(granted.completedRewardedRentClaimIds, {'reward-1'});
    expect(granted.rewardedRentBonusCount, 1);
    expect(duplicate, same(granted));
  });

  test('cancel retains base payout and never records a successful bonus', () {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 2000000);
    final begun = GameRules.beginRewardedRentClaim(
      initial,
      'reward-1',
      '2026-10-14',
    );

    final cancelled = GameRules.cancelRewardedRentClaim(begun, 'reward-1');

    expect(cancelled.walletCoins, 202);
    expect(cancelled.pendingRewardedRentClaim, isNull);
    expect(cancelled.completedRewardedRentClaimIds, isEmpty);
    expect(
      GameRules.grantRewardedRentBonus(cancelled, 'reward-1'),
      same(cancelled),
    );
  });

  test('daily cap blocks a fourth bonus and resets on a new local day', () {
    final capped = GameState.seeded().copyWith(
      pendingRentMicrocoins: GameBalance.microcoinsPerCoin,
      rewardedRentBonusDayKey: '2026-10-14',
      rewardedRentBonusCount: 3,
    );

    expect(RewardedRentSystem.remainingForDay(capped, '2026-10-14'), 0);
    expect(
      GameRules.beginRewardedRentClaim(capped, 'blocked', '2026-10-14'),
      same(capped),
    );

    final nextDay = GameRules.beginRewardedRentClaim(
      capped,
      'next-day',
      '2026-10-15',
    );
    final granted = GameRules.grantRewardedRentBonus(nextDay, 'next-day');
    expect(granted.rewardedRentBonusDayKey, '2026-10-15');
    expect(granted.rewardedRentBonusCount, 1);
  });

  test('blank, overlapping, duplicate, and sub-coin offers are no-ops', () {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 999999);
    expect(
      GameRules.beginRewardedRentClaim(initial, 'claim', '2026-10-14'),
      same(initial),
    );

    final eligible = initial.copyWith(pendingRentMicrocoins: 1000000);
    expect(
      GameRules.beginRewardedRentClaim(eligible, '', '2026-10-14'),
      same(eligible),
    );
    final begun = GameRules.beginRewardedRentClaim(
      eligible,
      'claim',
      '2026-10-14',
    );
    final overlapping = begun.copyWith(pendingRentMicrocoins: 1000000);
    expect(
      GameRules.beginRewardedRentClaim(overlapping, 'other', '2026-10-14'),
      same(overlapping),
    );
  });
}
