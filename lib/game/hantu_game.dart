import 'dart:ui' as ui;

import 'package:flame/camera.dart';
import 'package:flame/game.dart';

import 'assets/game_assets.dart';
import '../simulation/models/game_state.dart';
import '../simulation/models/ghost.dart';
import '../simulation/systems/happiness_system.dart';
import 'world/kontrakan_world.dart';

class HantuGame extends FlameGame {
  HantuGame({
    required this.state,
    required this.onRoomTap,
    required this.onGhostTap,
    required this.roomLabelFor,
    required this.happinessLabelFor,
    required this.lockedLabel,
  }) : super(
         camera: CameraComponent.withFixedResolution(width: 360, height: 360),
       );

  final GameState state;
  final void Function(String roomId) onRoomTap;
  final void Function(String ghostId) onGhostTap;
  final String Function(String roomId) roomLabelFor;
  final String Function(int happiness) happinessLabelFor;
  final String lockedLabel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final cutawayImage = await images.load(GameAssets.cutaway);
    final ghostAtlases = <GhostKind, ui.Image>{
      for (final entry in GameAssets.ghostAtlases.entries)
        entry.key: await images.load(entry.value),
    };
    world.add(
      KontrakanWorld(
        state: state,
        happinessFor: (id) => HappinessSystem.happinessFor(state, id),
        onRoomTap: onRoomTap,
        onGhostTap: onGhostTap,
        roomLabelFor: roomLabelFor,
        happinessLabelFor: happinessLabelFor,
        lockedLabel: lockedLabel,
        cutawayImage: cutawayImage,
        ghostAtlases: ghostAtlases,
      ),
    );
  }
}
