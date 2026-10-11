import 'package:flutter/foundation.dart';

import '../services/save_service.dart';
import '../simulation/models/game_state.dart';
import '../simulation/systems/game_rules.dart';
import '../simulation/systems/happiness_system.dart';

class GameController extends ChangeNotifier {
  GameController({required SaveService saveService})
    : _saveService = saveService;

  final SaveService _saveService;
  GameState _state = GameState.seeded();
  bool _isReady = false;
  int _revision = 0;

  GameState get state => _state;
  bool get isReady => _isReady;
  int get revision => _revision;
  bool get hasPendingComplaint => !_state.complaintResolved;

  int happinessFor(String ghostId) =>
      HappinessSystem.happinessFor(_state, ghostId);
  int compatibilityFor(String ghostId) =>
      HappinessSystem.compatibilityFor(_state, ghostId);

  Future<void> initialize() async {
    _state = await _saveService.load() ?? GameState.seeded();
    _isReady = true;
    notifyListeners();
  }

  Future<void> swapFrom(String roomId) async {
    await _commit(GameRules.swapOccupants(_state, roomId));
  }

  Future<void> resolveComplaint(ComplaintChoice choice) async {
    await _commit(
      GameRules.resolveComplaint(_state, choice, 'p0_complaint_resolution'),
    );
  }

  Future<void> _commit(GameState nextState) async {
    if (identical(nextState, _state)) return;
    _state = nextState;
    _revision += 1;
    notifyListeners();
    await _saveService.save(_state);
  }
}
