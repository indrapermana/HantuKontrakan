import 'package:flutter/foundation.dart';

import '../services/save_service.dart';
import '../simulation/commands/game_command.dart';
import '../simulation/constants/game_balance.dart';
import '../simulation/game_state_controller.dart';
import '../simulation/models/game_state.dart';
import '../simulation/systems/game_rules.dart';
import '../simulation/systems/happiness_system.dart';

class GameController extends ChangeNotifier {
  GameController({required SaveService saveService})
    : _saveService = saveService;

  final SaveService _saveService;
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

  int happinessFor(String ghostId) =>
      HappinessSystem.happinessFor(state, ghostId);
  int compatibilityFor(String ghostId) =>
      HappinessSystem.compatibilityFor(state, ghostId);

  Future<void> initialize() async {
    _loadResult = await _saveService.load();
    _domainController = GameStateController(switch (_loadResult) {
      SaveLoaded(:final state) => state,
      SaveNotFound() || SaveRejected() => GameState.seeded(),
    });
    _isReady = true;
    notifyListeners();
  }

  Future<void> swapFrom(String roomId) async {
    await _dispatch(SwapOccupants(roomId: roomId));
  }

  Future<void> resolveComplaint(ComplaintChoice choice) async {
    await _dispatch(
      ResolveComplaint(
        choice: choice,
        resolutionId: GameBalance.p0ComplaintResolutionId,
      ),
    );
  }

  Future<void> _dispatch(GameCommand command) async {
    if (!_domainController.dispatch(command)) return;
    notifyListeners();
    await _saveService.save(state);
  }
}
