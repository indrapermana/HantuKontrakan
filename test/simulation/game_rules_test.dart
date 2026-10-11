import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test('swap is atomic and preserves one-to-one occupancy', () {
    final initial = GameState.seeded();
    final swapped = GameRules.swapOccupants(initial, 'room_01');

    expect(swapped.roomById('room_01').occupantId, 'tuyul_01');
    expect(swapped.roomById('room_02').occupantId, 'pocong_01');
    expect(swapped.rooms.map((room) => room.occupantId).toSet(), hasLength(2));
  });

  test('complaint choice applies exact effects only once', () {
    final initial = GameState.seeded();
    final resolved = GameRules.resolveComplaint(
      initial,
      ComplaintChoice.installSoundproofing,
      'resolution-1',
    );
    final replayed = GameRules.resolveComplaint(
      resolved,
      ComplaintChoice.installSoundproofing,
      'resolution-1',
    );

    expect(resolved.walletCoins, 150);
    expect(resolved.ghostById('pocong_01').eventHappinessModifier, 20);
    expect(resolved.complaintResolved, isTrue);
    expect(identical(replayed, resolved), isTrue);
  });
}
