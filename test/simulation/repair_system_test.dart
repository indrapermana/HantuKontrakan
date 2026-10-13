import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/offline_earnings_system.dart';
import 'package:hantu_kontrakan/simulation/systems/repair_system.dart';

void main() {
  test('durability levels reduce repair cost to 100, 80, and 60', () {
    expect(RepairSystem.costFor(_state(durabilityLevel: 0), 'room_01'), 100);
    expect(RepairSystem.costFor(_state(durabilityLevel: 1), 'room_01'), 80);
    expect(RepairSystem.costFor(_state(durabilityLevel: 2), 'room_01'), 60);
  });

  test('happy Genderuwo applies 25 percent discount after durability', () {
    final happy = _state(
      durabilityLevel: 1,
      ghost: const GhostState(id: 'genderuwo_01', kind: GhostKind.genderuwo),
      roomTagLevels: const {'sturdy': 1},
    );
    final unhappy = _state(
      durabilityLevel: 1,
      ghost: const GhostState(id: 'genderuwo_01', kind: GhostKind.genderuwo),
    );

    expect(RepairSystem.costFor(happy, 'room_01'), 60);
    expect(RepairSystem.costFor(unhappy, 'room_01'), 80);
  });

  test('repair charges and clears damage atomically only once', () {
    final damaged = _state(durabilityLevel: 1);
    final repaired = GameRules.repairRoom(damaged, 'room_01', 'repair-1');
    final replayed = GameRules.repairRoom(repaired, 'room_01', 'repair-1');
    final retried = GameRules.repairRoom(repaired, 'room_01', 'repair-2');

    expect(repaired.walletCoins, 120);
    expect(repaired.roomById('room_01').repairRequired, isFalse);
    expect(repaired.completedRepairIds, {'repair-1'});
    expect(identical(replayed, repaired), isTrue);
    expect(identical(retried, repaired), isTrue);
  });

  test('invalid and unaffordable repairs are identity-preserving no-ops', () {
    final damaged = _state(walletCoins: 50);

    expect(
      identical(GameRules.repairRoom(damaged, 'room_01', 'repair-1'), damaged),
      isTrue,
    );
    expect(
      identical(GameRules.repairRoom(damaged, 'missing', 'repair-2'), damaged),
      isTrue,
    );
    expect(
      identical(GameRules.repairRoom(damaged, 'room_01', '   '), damaged),
      isTrue,
    );
  });

  test('repair state and completed IDs survive JSON continuation', () {
    final damaged = _state(durabilityLevel: 2);
    final restored = GameState.fromJson(
      jsonDecode(jsonEncode(damaged.toJson())) as Map<String, Object?>,
    );
    final repaired = GameRules.repairRoom(restored, 'room_01', 'repair-json');
    final replayed = GameRules.repairRoom(
      GameState.fromJson(
        jsonDecode(jsonEncode(repaired.toJson())) as Map<String, Object?>,
      ),
      'room_01',
      'repair-json',
    );

    expect(restored.roomById('room_01').repairRequired, isTrue);
    expect(repaired.walletCoins, 140);
    expect(replayed.walletCoins, 140);
    expect(replayed.completedRepairIds, {'repair-json'});
  });

  test('offline resume never repairs or charges a damaged room', () {
    final damaged = _state();
    final paused = OfflineEarningsSystem.pause(damaged, 0);
    final resumed = OfflineEarningsSystem.resume(paused, 600000);

    expect(resumed.roomById('room_01').repairRequired, isTrue);
    expect(resumed.walletCoins, damaged.walletCoins);
    expect(resumed.completedRepairIds, isEmpty);
  });
}

GameState _state({
  int durabilityLevel = 0,
  int walletCoins = 200,
  GhostState ghost = const GhostState(id: 'pocong_01', kind: GhostKind.pocong),
  Map<String, int> roomTagLevels = const {},
}) => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: walletCoins,
  ghosts: [ghost],
  rooms: [
    RoomState(
      id: 'room_01',
      column: 0,
      occupantId: ghost.id,
      repairRequired: true,
      upgrades: durabilityLevel == 0
          ? const {}
          : {RoomAttribute.durability: durabilityLevel},
      roomTagLevels: roomTagLevels,
    ),
  ],
  complaintResolved: false,
);
