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
      RoomState(id: 'room_01', column: 0, occupantId: 'pocong_01'),
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
      () => state.rooms.add(RoomState(id: 'room_02', column: 1)),
      throwsUnsupportedError,
    );
  });

  test('pure controller dispatches typed commands deterministically', () {
    final initial = GameState.seeded();
    final controller = GameStateController(initial);

    expect(
      controller.dispatch(
        const MoveGhost(
          ghostId: 'pocong_01',
          targetRoomId: 'room_02',
          allowSwap: true,
        ),
      ),
      isTrue,
    );
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

  test(
    'language commands accept only supported values and avoid duplicates',
    () {
      final controller = GameStateController(GameState.seeded());

      expect(
        controller.dispatch(const SetLanguageCode(languageCode: 'en')),
        isTrue,
      );
      expect(controller.state.languageCode, 'en');
      expect(controller.revision, 1);

      expect(
        controller.dispatch(const SetLanguageCode(languageCode: 'en')),
        isFalse,
      );
      expect(
        controller.dispatch(const SetLanguageCode(languageCode: 'fr')),
        isFalse,
      );
      expect(controller.revision, 1);
    },
  );

  test('analytics consent is an explicit idempotent domain command', () {
    final controller = GameStateController(GameState.seeded());

    expect(
      controller.dispatch(const SetAnalyticsConsent(granted: true)),
      isTrue,
    );
    expect(controller.state.analyticsConsentGranted, isTrue);
    expect(
      controller.dispatch(const SetAnalyticsConsent(granted: true)),
      isFalse,
    );
    expect(
      controller.dispatch(const SetAnalyticsConsent(granted: false)),
      isTrue,
    );
    expect(controller.state.analyticsConsentGranted, isFalse);
  });

  test('error-reporting consent is an explicit idempotent domain command', () {
    final controller = GameStateController(GameState.seeded());

    expect(
      controller.dispatch(const SetErrorReportingConsent(granted: true)),
      isTrue,
    );
    expect(controller.state.errorReportingConsentGranted, isTrue);
    expect(
      controller.dispatch(const SetErrorReportingConsent(granted: true)),
      isFalse,
    );
    expect(
      controller.dispatch(const SetErrorReportingConsent(granted: false)),
      isTrue,
    );
    expect(controller.state.errorReportingConsentGranted, isFalse);
  });

  test('audio settings validate ranges and update atomically', () {
    final controller = GameStateController(GameState.seeded());

    expect(
      controller.dispatch(
        const SetAudioPreferences(
          musicMuted: true,
          soundMuted: false,
          musicVolume: 0.2,
          soundVolume: 0.8,
        ),
      ),
      isTrue,
    );
    expect(controller.state.musicMuted, isTrue);
    expect(controller.state.musicVolume, 0.2);
    expect(
      controller.dispatch(
        const SetAudioPreferences(
          musicMuted: false,
          soundMuted: false,
          musicVolume: -0.1,
          soundVolume: 0.8,
        ),
      ),
      isFalse,
    );
    expect(controller.state.musicMuted, isTrue);
    expect(controller.state.musicVolume, 0.2);
  });

  test('game state rejects invalid one-to-one occupancy', () {
    expect(
      () => GameState(
        schemaVersion: GameState.currentSchemaVersion,
        walletCoins: 200,
        ghosts: const [GhostState(id: 'pocong_01', kind: GhostKind.pocong)],
        rooms: [
          RoomState(id: 'room_01', column: 0, occupantId: 'pocong_01'),
          RoomState(id: 'room_02', column: 1, occupantId: 'pocong_01'),
        ],
        complaintResolved: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => GameState(
        schemaVersion: GameState.currentSchemaVersion,
        walletCoins: 200,
        ghosts: const [GhostState(id: 'pocong_01', kind: GhostKind.pocong)],
        rooms: [RoomState(id: 'room_01', column: 0, occupantId: 'missing')],
        complaintResolved: false,
      ),
      throwsArgumentError,
    );
  });

  test('debug tick validates elapsed time and reset restores seed state', () {
    final controller = GameStateController(GameState.seeded());

    expect(controller.dispatch(const AdvanceSimulation(seconds: 0)), isFalse);
    expect(controller.revision, 0);
    expect(controller.dispatch(const AdvanceSimulation(seconds: 3)), isTrue);
    expect(controller.state.activeSimulationSeconds, 3);

    expect(controller.dispatch(const ResetGame()), isTrue);
    expect(controller.state.activeSimulationSeconds, 0);
    expect(controller.state.chaos, GameBalance.initialChaos);
    expect(controller.state.walletCoins, GameBalance.initialCoins);
  });

  test('special animation command updates only the requested ghost', () {
    final controller = GameStateController(GameState.seeded());

    expect(
      controller.dispatch(
        const SetGhostSpecialAction(ghostId: 'pocong_01', active: true),
      ),
      isTrue,
    );
    expect(controller.state.ghostById('pocong_01').specialActionActive, isTrue);
    expect(controller.state.ghostById('tuyul_01').specialActionActive, isFalse);
    expect(
      controller.dispatch(
        const SetGhostSpecialAction(ghostId: 'missing', active: true),
      ),
      isFalse,
    );
  });
}
