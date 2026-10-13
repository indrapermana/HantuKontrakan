import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/tutorial_step.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';
import 'package:hantu_kontrakan/simulation/systems/incident_system.dart';

void main() {
  test(
    'tutorial progresses through placement, rent, and scripted incident',
    () {
      var state = GameState.newGame();
      expect(state.tutorialStep, TutorialStep.openingStory);
      expect(state.unscriptedIncidentsEnabled, isFalse);
      expect(IncidentSystem.check(state), same(state));

      state = GameRules.continueTutorial(state);
      state = GameRules.placeGhost(state, 'pocong_01', 'room_01');
      expect(state.tutorialStep, TutorialStep.collectFirstRent);
      expect(
        state.pendingRentMicrocoins,
        GameBalance.tutorialFirstRentCoins * GameBalance.microcoinsPerCoin,
      );

      state = GameRules.collectAllRent(state, 'tutorial-rent');
      expect(state.walletCoins, 210);
      expect(state.playerExperience, 100);
      expect(state.playerLevel, 2);
      expect(state.tutorialStep, TutorialStep.placeKuntilanak);

      state = GameRules.placeGhost(state, 'kuntilanak_01', 'room_02');
      expect(state.tutorialStep, TutorialStep.resolveScriptedIncident);
      expect(state.activeIncidentId, GameBalance.tutorialIncidentId);
      expect(state.chaos, lessThan(70));

      state = GameRules.resolveIncident(
        state,
        GameBalance.tutorialIncidentId,
        'join_patrol',
        'tutorial-resolution',
      );
      expect(state.tutorialStep, TutorialStep.inspectLockedRoom);
      expect(state.activeIncidentId, isNull);
      expect(state.completedIncidentResolutionIds, {'tutorial-resolution'});

      state = GameRules.continueTutorial(state);
      expect(state.tutorialStep, TutorialStep.completed);
      expect(state.unscriptedIncidentsEnabled, isTrue);
    },
  );

  test(
    'tutorial progress round-trips and version 12 saves skip onboarding',
    () {
      final progressed = GameRules.placeGhost(
        GameRules.continueTutorial(GameState.newGame()),
        'pocong_01',
        'room_01',
      );
      expect(
        GameState.fromJson(progressed.toJson()).tutorialStep,
        TutorialStep.collectFirstRent,
      );

      final version12 = GameState.seeded().toJson()
        ..['schemaVersion'] = 12
        ..remove('tutorialStep');
      final migrated = GameState.fromJson(version12);
      expect(migrated.tutorialStep, TutorialStep.completed);
      expect(migrated.unscriptedIncidentsEnabled, isTrue);
    },
  );
}
