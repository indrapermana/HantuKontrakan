import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

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
  }) : super(camera: CameraComponent());

  final GameState state;
  final void Function(String roomId) onRoomTap;
  final void Function(String ghostId) onGhostTap;
  final String Function(String roomId) roomLabelFor;
  final String Function(int happiness) happinessLabelFor;
  final String lockedLabel;

  @override
  ui.Color backgroundColor() => const ui.Color(0xFF111631);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _frameCutawayWorld(viewportSize: size);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _frameCutawayWorld();
    ui.Image? cutawayImage;
    try {
      cutawayImage = await images.load(GameAssets.cutaway);
    } on Object catch (error) {
      debugPrint('Unable to load cutaway art: $error');
    }
    final ghostAtlases = <GhostKind, ui.Image>{};
    for (final entry in GameAssets.ghostAtlases.entries) {
      try {
        ghostAtlases[entry.key] = await images.load(entry.value);
      } on Object catch (error) {
        debugPrint('Unable to load ${entry.key.name} atlas: $error');
      }
    }
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

  void _frameCutawayWorld({Vector2? viewportSize}) {
    final width = viewportSize?.x ?? 360;
    camera.viewfinder
      ..anchor = Anchor.center
      ..position = Vector2(180, 260)
      ..zoom = (width / 330).clamp(0.85, 1.45);
  }
}
