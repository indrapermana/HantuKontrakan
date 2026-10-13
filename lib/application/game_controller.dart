import 'package:flutter/foundation.dart';

import '../services/save_service.dart';
import '../simulation/commands/game_command.dart';
import '../simulation/constants/game_balance.dart';
import '../simulation/game_state_controller.dart';
import '../simulation/models/game_state.dart';
import '../simulation/models/room.dart';
import '../simulation/systems/game_rules.dart';
import '../simulation/systems/happiness_system.dart';
import '../simulation/systems/repair_system.dart';
import 'simulation_runtime.dart';

class GameController extends ChangeNotifier {
  GameController({
    required SaveService saveService,
    GameClock clock = const SystemGameClock(),
    int randomSeed = GameBalance.defaultRandomSeed,
  }) : _saveService = saveService,
       _clock = clock,
       _randomSource = SeededRandomSource(randomSeed);

  final SaveService _saveService;
  final GameClock _clock;
  final SeededRandomSource _randomSource;
  int _rentClaimSequence = 0;
  int _repairSequence = 0;
  Future<void> _lifecycleOperation = Future<void>.value();
  GameStateController _domainController = GameStateController(
    GameState.seeded(),
  );
  bool _isReady = false;
  SaveLoadResult _loadResult = const SaveNotFound();

  GameState get state => _domainController.state;
  bool get isReady => _isReady;
  int get revision => _domainController.revision;
  bool get hasPendingComplaint => !state.complaintResolved;
  SaveLoadResult get loadResult => _loadResult;
  SaveRejectionReason? get saveRecoveryReason => switch (_loadResult) {
    SaveRejected(:final reason) => reason,
    _ => null,
  };
  DateTime get debugNow => _clock.now();
  int get randomSeed => _randomSource.seed;

  int happinessFor(String ghostId) =>
      HappinessSystem.happinessFor(state, ghostId);
  int compatibilityFor(String ghostId) =>
      HappinessSystem.compatibilityFor(state, ghostId);
  int get pendingRentCoins =>
      state.pendingRentMicrocoins ~/ GameBalance.microcoinsPerCoin;
  int repairCostFor(String roomId) => RepairSystem.costFor(state, roomId);

  Future<void> initialize() async {
    _loadResult = await _saveService.load();
    _domainController = GameStateController(switch (_loadResult) {
      SaveLoaded(:final state) => state,
      SaveNotFound() => GameState.newGame(),
      SaveRejected() => GameState.seeded(),
    });
    final resumed = _domainController.dispatch(
      ResumeFromOffline(timestampMillis: _clock.now().millisecondsSinceEpoch),
    );
    if (resumed) await _saveService.save(state);
    _isReady = true;
    notifyListeners();
  }

  Future<void> placeGhost(String ghostId, String roomId) async {
    await _dispatch(PlaceGhost(ghostId: ghostId, roomId: roomId));
  }

  Future<void> continueTutorial() async {
    await _dispatch(const ContinueTutorial());
  }

  Future<void> grantExperience(int amount) async {
    await _dispatch(GrantExperience(amount: amount));
  }

  Future<bool> claimMissionReward(String missionId) =>
      _dispatch(ClaimMissionReward(missionId: missionId));

  Future<void> moveGhost(
    String ghostId,
    String targetRoomId, {
    bool allowSwap = false,
  }) async {
    await _dispatch(
      MoveGhost(
        ghostId: ghostId,
        targetRoomId: targetRoomId,
        allowSwap: allowSwap,
      ),
    );
  }

  Future<void> unlockRoom(String roomId) async {
    await _dispatch(UnlockRoom(roomId: roomId));
  }

  Future<void> upgradeRoom(String roomId, RoomAttribute attribute) async {
    await _dispatch(UpgradeRoom(roomId: roomId, attribute: attribute));
  }

  Future<void> equipFurniture(
    String roomId,
    String furnitureId,
    FurnitureSlot slot,
  ) async {
    await _dispatch(
      EquipFurniture(roomId: roomId, furnitureId: furnitureId, slot: slot),
    );
  }

  Future<void> resolveComplaint(ComplaintChoice choice) async {
    await _dispatch(
      ResolveComplaint(
        choice: choice,
        resolutionId: GameBalance.p0ComplaintResolutionId,
      ),
    );
  }

  Future<void> debugTick() async {
    await advanceSimulation(GameBalance.debugTickSeconds);
  }

  Future<void> advanceSimulation(int elapsedSeconds) async {
    await _dispatch(AdvanceSimulation(seconds: elapsedSeconds));
  }

  Future<void> collectAllRent({String? claimId}) async {
    final resolvedClaimId =
        claimId ??
        'rent-${_clock.now().microsecondsSinceEpoch}-$revision-${_rentClaimSequence++}';
    await _dispatch(CollectAllRent(claimId: resolvedClaimId));
  }

  Future<bool> resolveIncident(
    String incidentId,
    String choiceId, {
    String? resolutionId,
  }) async {
    final resolvedId =
        resolutionId ??
        'incident-$incidentId-$choiceId-${state.activeSimulationSeconds}';
    return _dispatch(
      ResolveIncident(
        incidentId: incidentId,
        choiceId: choiceId,
        resolutionId: resolvedId,
      ),
    );
  }

  Future<bool> repairRoom(String roomId, {String? repairId}) async {
    final resolvedRepairId =
        repairId ??
        'repair-$roomId-${_clock.now().microsecondsSinceEpoch}-$revision-${_repairSequence++}';
    return _dispatch(RepairRoom(roomId: roomId, repairId: resolvedRepairId));
  }

  Future<void> pauseForOffline() async {
    if (!_isReady) return;
    final timestampMillis = _clock.now().millisecondsSinceEpoch;
    _lifecycleOperation = _lifecycleOperation.then((_) async {
      await _dispatch(PauseForOffline(timestampMillis: timestampMillis));
    });
    await _lifecycleOperation;
  }

  Future<void> resumeFromOffline() async {
    if (!_isReady) return;
    final timestampMillis = _clock.now().millisecondsSinceEpoch;
    _lifecycleOperation = _lifecycleOperation.then((_) async {
      await _dispatch(ResumeFromOffline(timestampMillis: timestampMillis));
    });
    await _lifecycleOperation;
  }

  Future<void> resetState() async {
    _randomSource.reset();
    await _dispatch(const ResetGame());
  }

  Future<void> setGhostSpecialAction(String ghostId, bool active) async {
    await _dispatch(SetGhostSpecialAction(ghostId: ghostId, active: active));
  }

  Future<bool> _dispatch(GameCommand command) async {
    if (!_domainController.dispatch(command)) return false;
    notifyListeners();
    await _saveService.save(state);
    return true;
  }
}
