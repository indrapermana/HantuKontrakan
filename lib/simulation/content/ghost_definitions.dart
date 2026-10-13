import '../models/ghost.dart';
import '../models/ghost_definition.dart';

abstract final class GhostDefinitions {
  static const Map<GhostKind, GhostDefinition> all = {
    GhostKind.pocong: GhostDefinition(
      kind: GhostKind.pocong,
      baseRentPerMinute: 10,
      unlockLevel: 1,
      chaosPerTenMinutes: 3,
      preferredRoomTags: ['quiet'],
      positiveNeighbor: GhostKind.genderuwo,
      dislikedNeighbor: GhostKind.tuyul,
      abilityId: 'lost_coins',
    ),
    GhostKind.kuntilanak: GhostDefinition(
      kind: GhostKind.kuntilanak,
      baseRentPerMinute: 14,
      unlockLevel: 2,
      chaosPerTenMinutes: 2,
      preferredRoomTags: ['plant', 'decorated'],
      positiveNeighbor: GhostKind.pocong,
      dislikedNeighbor: GhostKind.genderuwo,
      abilityId: 'neighborhood_reputation',
    ),
    GhostKind.tuyul: GhostDefinition(
      kind: GhostKind.tuyul,
      baseRentPerMinute: 12,
      unlockLevel: 3,
      chaosPerTenMinutes: 6,
      preferredRoomTags: ['mystical', 'shiny'],
      positiveNeighbor: GhostKind.kuntilanak,
      dislikedNeighbor: GhostKind.pocong,
      abilityId: 'base_rent_bonus',
    ),
    GhostKind.genderuwo: GhostDefinition(
      kind: GhostKind.genderuwo,
      baseRentPerMinute: 18,
      unlockLevel: 5,
      chaosPerTenMinutes: -1,
      preferredRoomTags: ['sturdy'],
      positiveNeighbor: GhostKind.pocong,
      dislikedNeighbor: GhostKind.tuyul,
      abilityId: 'repair_discount',
    ),
  };

  static GhostDefinition byKind(GhostKind kind) => all[kind]!;
}
