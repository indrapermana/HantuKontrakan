import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/game/assets/game_assets.dart';
import 'package:hantu_kontrakan/game/components/ghost_component.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GhostComponent component({
    int happiness = 50,
    bool special = false,
    GhostKind kind = GhostKind.pocong,
  }) => GhostComponent(
    ghost: GhostState(
      id: '${kind.name}_01',
      kind: kind,
      specialActionActive: special,
    ),
    happiness: happiness,
    position: Vector2.zero(),
    onTap: () {},
  );

  test('simulation state and happiness select placeholder animation', () {
    expect(component(happiness: 50).animationState, GhostAnimationState.idle);
    expect(component(happiness: 80).animationState, GhostAnimationState.happy);
    expect(component(happiness: 39).animationState, GhostAnimationState.angry);
    expect(
      component(happiness: 100, special: true).animationState,
      GhostAnimationState.special,
    );
  });

  test('all four ghost kinds support the procedural animation states', () {
    for (final kind in GhostKind.values) {
      final ghost = component(kind: kind, special: true);
      expect(ghost.animationState, GhostAnimationState.special);
      ghost.update(0.25);
      expect(ghost.angle, isNot(0));
    }
  });

  test('all four production atlases build state-driven animations', () async {
    for (final entry in GameAssets.ghostAtlases.entries) {
      final data = await rootBundle.load('assets/images/${entry.value}');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final ghost = GhostComponent(
        ghost: GhostState(id: '${entry.key.name}_01', kind: entry.key),
        happiness: 80,
        position: Vector2.zero(),
        onTap: () {},
        atlasImage: frame.image,
      );

      await ghost.onLoad();

      expect(ghost.usesAtlas, isTrue, reason: entry.key.name);
      expect(ghost.animationState, GhostAnimationState.happy);
      ghost.update(0.2);
      expect(ghost.angle, 0);

      frame.image.dispose();
      codec.dispose();
    }
  });
}
