import '../constants/game_balance.dart';
import '../models/game_state.dart';
import '../models/tutorial_step.dart';

abstract final class TutorialSystem {
  static GameState continueTutorial(GameState state) {
    return switch (state.tutorialStep) {
      TutorialStep.openingStory => state.copyWith(
        tutorialStep: TutorialStep.placePocong,
      ),
      TutorialStep.inspectLockedRoom => state.copyWith(
        tutorialStep: TutorialStep.completed,
        unscriptedIncidentsEnabled: true,
      ),
      _ => state,
    };
  }

  static GameState afterPlacement(
    GameState state,
    String ghostId,
    String roomId,
  ) {
    if (state.tutorialStep == TutorialStep.placePocong &&
        ghostId == 'pocong_01' &&
        roomId == 'room_01') {
      return state.copyWith(
        tutorialStep: TutorialStep.collectFirstRent,
        pendingRentMicrocoins:
            state.pendingRentMicrocoins +
            GameBalance.tutorialFirstRentCoins * GameBalance.microcoinsPerCoin,
      );
    }
    if (state.tutorialStep == TutorialStep.placeKuntilanak &&
        ghostId == 'kuntilanak_01' &&
        roomId == 'room_02') {
      return state.copyWith(
        tutorialStep: TutorialStep.resolveScriptedIncident,
        activeIncidentId: GameBalance.tutorialIncidentId,
      );
    }
    return state;
  }

  static GameState afterRentCollection(GameState state) {
    if (state.tutorialStep != TutorialStep.collectFirstRent) return state;
    return state.copyWith(tutorialStep: TutorialStep.placeKuntilanak);
  }

  static GameState afterIncidentResolution(GameState state, String incidentId) {
    if (state.tutorialStep != TutorialStep.resolveScriptedIncident ||
        incidentId != GameBalance.tutorialIncidentId) {
      return state;
    }
    return state.copyWith(tutorialStep: TutorialStep.inspectLockedRoom);
  }
}
