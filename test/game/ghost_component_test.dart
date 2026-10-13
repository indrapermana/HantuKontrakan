import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/game/components/ghost_component.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';

void main() {
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
}
