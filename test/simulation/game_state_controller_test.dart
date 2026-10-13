import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/commands/game_command.dart';
import 'package:hantu_kontrakan/simulation/constants/game_balance.dart';
import 'package:hantu_kontrakan/simulation/game_state_controller.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test('game state defensively freezes collection inputs', () {
    final ghosts = <GhostState>[
      const GhostState(id: 'pocong_01', kind: GhostKind.pocong),
    ];
    final rooms = <RoomState>[
      const RoomState(id: 'room_01', column: 0, occupantId: 'pocong_01'),
    ];
    final state = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: GameBalance.initialCoins,
      ghosts: ghosts,
      rooms: rooms,
      complaintResolved: false,
    );

    ghosts.clear();
    rooms.clear();

    expect(state.ghosts, hasLength(1));
    expect(state.rooms, hasLength(1));
    expect(
      () => state.ghosts.add(
        const GhostState(id: 'tuyul_01', kind: GhostKind.tuyul),
      ),
      throwsUnsupportedError,
    );
    expect(
      () => state.rooms.add(const RoomState(id: 'room_02', column: 1)),
      throwsUnsupportedError,
    );
  });

  test('pure controller dispatches typed commands deterministically', () {
    final initial = GameState.seeded();
    final controller = GameStateController(initial);

    expect(controller.dispatch(const SwapOccupants(roomId: 'room_01')), isTrue);
    expect(controller.revision, 1);
    expect(controller.state.roomById('room_01').occupantId, 'tuyul_01');
    expect(initial.roomById('room_01').occupantId, 'pocong_01');

    expect(
      controller.dispatch(
        const ResolveComplaint(
          choice: ComplaintChoice.installSoundproofing,
          resolutionId: GameBalance.p0ComplaintResolutionId,
        ),
      ),
      isTrue,
    );
    expect(controller.revision, 2);
    expect(controller.state.walletCoins, 150);

    expect(
      controller.dispatch(
        const ResolveComplaint(
          choice: ComplaintChoice.installSoundproofing,
          resolutionId: GameBalance.p0ComplaintResolutionId,
        ),
      ),
      isFalse,
    );
    expect(controller.revision, 2);
    expect(controller.state.walletCoins, 150);
  });
}
