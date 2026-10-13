import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/content/progression_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/progression_system.dart';

void main() {
  test('defines exact cumulative thresholds and planned unlocks', () {
    expect(
      ProgressionDefinitions.levels.map(
        (definition) => definition.requiredExperience,
      ),
      [0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200],
    );
    expect(ProgressionDefinitions.byLevel(2).unlockedGhostKinds, {
      GhostKind.kuntilanak,
    });
    expect(ProgressionDefinitions.byLevel(3).unlockedGhostKinds, {
      GhostKind.tuyul,
    });
    expect(ProgressionDefinitions.byLevel(3).unlockedRoomIds, {'room_03'});
    expect(ProgressionDefinitions.byLevel(5).unlockedGhostKinds, {
      GhostKind.genderuwo,
    });
    expect(ProgressionDefinitions.byLevel(5).unlockedRoomIds, {'room_04'});
  });

  test('level calculation is deterministic at every threshold boundary', () {
    for (final definition in ProgressionDefinitions.levels) {
      expect(
        ProgressionSystem.levelForExperience(definition.requiredExperience),
        definition.level,
      );
      if (definition.level > 1) {
        expect(
          ProgressionSystem.levelForExperience(
            definition.requiredExperience - 1,
          ),
          definition.level - 1,
        );
      }
    }
  });

  test('experience grants are chunk independent, capped, and reload safe', () {
    final initial = GameState.newGame();
    final single = ProgressionSystem.grantExperience(initial, 800);
    var chunked = initial;
    for (final amount in [100, 150, 200, 350]) {
      chunked = ProgressionSystem.grantExperience(chunked, amount);
    }
    final restored = GameState.fromJson(single.toJson());

    expect(single.playerExperience, 800);
    expect(single.playerLevel, 5);
    expect(chunked.playerExperience, single.playerExperience);
    expect(chunked.playerLevel, single.playerLevel);
    expect(restored.playerExperience, 800);
    expect(restored.playerLevel, 5);

    final capped = ProgressionSystem.grantExperience(single, 100000);
    expect(capped.playerExperience, 3200);
    expect(capped.playerLevel, 10);
    expect(ProgressionSystem.grantExperience(capped, 1), same(capped));
    expect(ProgressionSystem.grantExperience(capped, 0), same(capped));
    expect(ProgressionSystem.grantExperience(capped, -1), same(capped));
  });

  test('ghost placement and paid rooms use persisted level gates', () {
    var state = GameState.newGame();
    expect(
      GameRules.placeGhost(state, 'kuntilanak_01', 'room_02'),
      same(state),
    );
    expect(ProgressionSystem.isGhostUnlocked(state, GhostKind.pocong), isTrue);
    expect(ProgressionSystem.isGhostUnlocked(state, GhostKind.tuyul), isFalse);

    state = ProgressionSystem.grantExperience(state, 250);
    expect(state.playerLevel, 3);
    expect(ProgressionSystem.isGhostUnlocked(state, GhostKind.tuyul), isTrue);
    state = state.copyWith(walletCoins: 400);
    final unlocked = GameRules.unlockRoom(state, 'room_03');
    expect(unlocked.roomById('room_03').unlocked, isTrue);
    expect(unlocked.walletCoins, 0);

    final restored = GameState.fromJson(unlocked.toJson());
    expect(restored.playerExperience, 250);
    expect(restored.playerLevel, 3);
    expect(ProgressionSystem.isRoomEligible(restored, 'room_03'), isTrue);
  });
}
