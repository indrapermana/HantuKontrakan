import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/content/ghost_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';

void main() {
  test('all four ghost definitions match the implementation plan', () {
    expect(GhostDefinitions.all.keys.toSet(), GhostKind.values.toSet());

    final pocong = GhostDefinitions.byKind(GhostKind.pocong);
    expect(
      (pocong.baseRentPerMinute, pocong.unlockLevel, pocong.chaosPerTenMinutes),
      (10, 1, 3),
    );
    expect(pocong.preferredRoomTags, ['quiet']);
    expect(pocong.positiveNeighbor, GhostKind.genderuwo);
    expect(pocong.dislikedNeighbor, GhostKind.tuyul);

    final kuntilanak = GhostDefinitions.byKind(GhostKind.kuntilanak);
    expect(
      (
        kuntilanak.baseRentPerMinute,
        kuntilanak.unlockLevel,
        kuntilanak.chaosPerTenMinutes,
      ),
      (14, 2, 2),
    );
    expect(kuntilanak.preferredRoomTags, ['plant', 'decorated']);
    expect(kuntilanak.positiveNeighbor, GhostKind.pocong);
    expect(kuntilanak.dislikedNeighbor, GhostKind.genderuwo);

    final tuyul = GhostDefinitions.byKind(GhostKind.tuyul);
    expect(
      (tuyul.baseRentPerMinute, tuyul.unlockLevel, tuyul.chaosPerTenMinutes),
      (12, 3, 6),
    );
    expect(tuyul.preferredRoomTags, ['mystical', 'shiny']);
    expect(tuyul.positiveNeighbor, GhostKind.kuntilanak);
    expect(tuyul.dislikedNeighbor, GhostKind.pocong);

    final genderuwo = GhostDefinitions.byKind(GhostKind.genderuwo);
    expect(
      (
        genderuwo.baseRentPerMinute,
        genderuwo.unlockLevel,
        genderuwo.chaosPerTenMinutes,
      ),
      (18, 5, -1),
    );
    expect(genderuwo.preferredRoomTags, ['sturdy']);
    expect(genderuwo.positiveNeighbor, GhostKind.pocong);
    expect(genderuwo.dislikedNeighbor, GhostKind.tuyul);
  });
}
