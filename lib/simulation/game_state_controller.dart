import 'commands/game_command.dart';
import 'models/game_state.dart';
import 'systems/game_rules.dart';

class GameStateController {
  GameStateController(GameState initialState) : _state = initialState;

  GameState _state;
  int _revision = 0;

  GameState get state => _state;
  int get revision => _revision;

  bool dispatch(GameCommand command) {
    final nextState = switch (command) {
      PlaceGhost(:final ghostId, :final roomId) => GameRules.placeGhost(
        _state,
        ghostId,
        roomId,
      ),
      MoveGhost(:final ghostId, :final targetRoomId, :final allowSwap) =>
        GameRules.moveGhost(
          _state,
          ghostId,
          targetRoomId,
          allowSwap: allowSwap,
        ),
      UnlockRoom(:final roomId) => GameRules.unlockRoom(_state, roomId),
      UpgradeRoom(:final roomId, :final attribute) => GameRules.upgradeRoom(
        _state,
        roomId,
        attribute,
      ),
      EquipFurniture(:final roomId, :final furnitureId, :final slot) =>
        GameRules.equipFurniture(_state, roomId, furnitureId, slot),
      ResolveComplaint(:final choice, :final resolutionId) =>
        GameRules.resolveComplaint(_state, choice, resolutionId),
      AdvanceSimulation(:final seconds) => GameRules.advanceSimulation(
        _state,
        seconds,
      ),
      CollectAllRent(:final claimId) => GameRules.collectAllRent(
        _state,
        claimId,
      ),
      CollectRoomRent(:final roomId, :final claimId) =>
        GameRules.collectRoomRent(_state, roomId, claimId),
      BeginRewardedRentClaim(
        :final claimId,
        :final localDayKey,
        :final bonusCoins,
      ) =>
        GameRules.beginRewardedRentClaim(
          _state,
          claimId,
          localDayKey,
          bonusCoins,
        ),
      GrantRewardedRentBonus(:final claimId) =>
        GameRules.grantRewardedRentBonus(_state, claimId),
      CancelRewardedRentClaim(:final claimId) =>
        GameRules.cancelRewardedRentClaim(_state, claimId),
      ContinueTutorial() => GameRules.continueTutorial(_state),
      GrantExperience(:final amount) => GameRules.grantExperience(
        _state,
        amount,
      ),
      ClaimMissionReward(:final missionId) => GameRules.claimMissionReward(
        _state,
        missionId,
      ),
      SetLanguageCode(:final languageCode) => GameRules.setLanguageCode(
        _state,
        languageCode,
      ),
      SetAnalyticsConsent(:final granted) => GameRules.setAnalyticsConsent(
        _state,
        granted,
      ),
      SetErrorReportingConsent(:final granted) =>
        GameRules.setErrorReportingConsent(_state, granted),
      SetAudioPreferences(
        :final musicMuted,
        :final soundMuted,
        :final musicVolume,
        :final soundVolume,
      ) =>
        GameRules.setAudioPreferences(
          _state,
          musicMuted: musicMuted,
          soundMuted: soundMuted,
          musicVolume: musicVolume,
          soundVolume: soundVolume,
        ),
      ResolveIncident(
        :final incidentId,
        :final choiceId,
        :final resolutionId,
      ) =>
        GameRules.resolveIncident(_state, incidentId, choiceId, resolutionId),
      RepairRoom(:final roomId, :final repairId) => GameRules.repairRoom(
        _state,
        roomId,
        repairId,
      ),
      PauseForOffline(:final timestampMillis) => GameRules.pauseForOffline(
        _state,
        timestampMillis,
      ),
      ResumeFromOffline(:final timestampMillis) => GameRules.resumeFromOffline(
        _state,
        timestampMillis,
      ),
      ResetGame() => GameState.seeded(),
      SetGhostSpecialAction(:final ghostId, :final active) =>
        GameRules.setGhostSpecialAction(_state, ghostId, active),
    };
    if (identical(nextState, _state)) return false;

    _state = nextState;
    _revision += 1;
    return true;
  }
}
