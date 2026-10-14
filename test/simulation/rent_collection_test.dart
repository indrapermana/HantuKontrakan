import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test('collect all atomically pays whole coins and preserves fractions', () {
    final initial = GameState.seeded().copyWith(
      walletCoins: 100,
      pendingRentMicrocoins: 12345678,
      rentAccrualRemainder: 37,
    );

    final collected = GameRules.collectAllRent(initial, 'claim-1');

    expect(collected.walletCoins, 112);
    expect(collected.pendingRentMicrocoins, 345678);
    expect(collected.rentAccrualRemainder, 37);
    expect(collected.completedRentClaimIds, {'claim-1'});
  });

  test('replaying a completed claim is an identity-preserving no-op', () {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 2500000);
    final collected = GameRules.collectAllRent(initial, 'claim-1');

    expect(
      identical(GameRules.collectAllRent(collected, 'claim-1'), collected),
      isTrue,
    );
    expect(collected.walletCoins, initial.walletCoins + 2);
  });

  test('empty claims and sub-coin balances are not consumed or recorded', () {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 999999);

    expect(identical(GameRules.collectAllRent(initial, ''), initial), isTrue);
    expect(
      identical(GameRules.collectAllRent(initial, 'claim-too-early'), initial),
      isTrue,
    );
    expect(initial.completedRentClaimIds, isEmpty);
  });

  test('a new claim can collect rent accrued after an earlier payout', () {
    final initial = GameState.seeded().copyWith(pendingRentMicrocoins: 1500000);
    final first = GameRules.collectAllRent(initial, 'claim-1');
    final accrued = first.copyWith(pendingRentMicrocoins: 2750000);
    final second = GameRules.collectAllRent(accrued, 'claim-2');

    expect(second.walletCoins, initial.walletCoins + 3);
    expect(second.pendingRentMicrocoins, 750000);
    expect(second.completedRentClaimIds, {'claim-1', 'claim-2'});
  });

  test('room claim plus collect all cannot duplicate another room', () {
    final initial = GameState.seeded().copyWith(
      walletCoins: 100,
      pendingRentMicrocoinsByRoom: const {
        'room_01': 2250000,
        'room_02': 1750000,
      },
    );

    final roomCollected = GameRules.collectRoomRent(
      initial,
      'room_01',
      'room-claim',
    );
    final allCollected = GameRules.collectAllRent(roomCollected, 'all-claim');

    expect(roomCollected.walletCoins, 102);
    expect(roomCollected.pendingRentMicrocoinsForRoom('room_01'), 250000);
    expect(roomCollected.pendingRentMicrocoinsForRoom('room_02'), 1750000);
    expect(allCollected.walletCoins, 103);
    expect(allCollected.pendingRentMicrocoinsForRoom('room_01'), 250000);
    expect(allCollected.pendingRentMicrocoinsForRoom('room_02'), 750000);
    expect(
      identical(
        GameRules.collectRoomRent(allCollected, 'room_01', 'room-claim'),
        allCollected,
      ),
      isTrue,
    );
  });
}
