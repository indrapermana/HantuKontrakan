import 'package:flame/camera.dart';
import 'package:flame/game.dart';

import '../simulation/models/game_state.dart';
import '../simulation/systems/happiness_system.dart';
import 'world/kontrakan_world.dart';

class HantuGame extends FlameGame {
  HantuGame({
    required this.state,
    required this.onRoomTap,
    required this.onGhostTap,
  }) : super(
         camera: CameraComponent.withFixedResolution(width: 360, height: 360),
       );

  final GameState state;
  final void Function(String roomId) onRoomTap;
  final void Function(String ghostId) onGhostTap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.add(
      KontrakanWorld(
        state: state,
        happinessFor: (id) => HappinessSystem.happinessFor(state, id),
        onRoomTap: onRoomTap,
        onGhostTap: onGhostTap,
      ),
    );
  }
}
