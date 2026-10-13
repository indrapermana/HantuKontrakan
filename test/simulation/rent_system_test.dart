import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/models/game_state.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/room.dart';
import 'package:hantu_kontrakan/simulation/systems/rent_system.dart';

void main() {
  test('worked Pocong example produces exactly 18.1125 coins per minute', () {
    final state = GameState(
      schemaVersion: GameState.currentSchemaVersion,
      walletCoins: 0,
      chaos: 42,
      ghosts: const [
        GhostState(
          id: 'pocong_01',
          kind: GhostKind.pocong,
          eventHappinessModifier: 10,
        ),
        GhostState(id: 'genderuwo_01', kind: GhostKind.genderuwo),
      ],
      rooms: [
        RoomState(
          id: 'room_01',
          column: 0,
          occupantId: 'pocong_01',
          upgrades: const {RoomAttribute.comfort: 1},
          roomTagLevels: const {'quiet': 2},
        ),
        RoomState(id: 'room_02', column: 1, occupantId: 'genderuwo_01'),
      ],
      complaintResolved: false,
    );

    expect(RentSystem.rentPerMinuteMicrocoinsFor(state, 'pocong_01'), 18112500);
  });

  test('Tuyul bonus is fifteen percent of base and not multiplied', () {
    final state = _singleGhostState(
      kind: GhostKind.tuyul,
      eventHappinessModifier: 10,
      chaos: 0,
    );

    expect(RentSystem.rentPerMinuteMicrocoinsFor(state, 'resident'), 13800000);
  });

  test('rent output is independent of elapsed-time chunk sizes', () {
    final initial = GameState.seeded();
    final oneChunk = RentSystem.accrue(initial, 601);
    var manyChunks = initial;
    for (var second = 0; second < 601; second += 1) {
      manyChunks = RentSystem.accrue(manyChunks, 1);
    }

    expect(manyChunks.pendingRentMicrocoins, oneChunk.pendingRentMicrocoins);
    expect(manyChunks.rentAccrualRemainder, oneChunk.rentAccrualRemainder);
    expect(manyChunks.activeSimulationSeconds, 601);
  });

  test('fractional microcoin remainder survives consecutive accrual', () {
    final initial = _singleGhostState(
      kind: GhostKind.pocong,
      chaos: 30,
      comfortLevel: 1,
    );
    final first = RentSystem.accrue(initial, 1);
    final continued = RentSystem.accrue(first, 59);
    final direct = RentSystem.accrue(initial, 60);

    expect(first.rentAccrualRemainder, isNonZero);
    expect(continued.pendingRentMicrocoins, direct.pendingRentMicrocoins);
    expect(continued.rentAccrualRemainder, direct.rentAccrualRemainder);
  });

  test('zero and negative elapsed time are identity-preserving no-ops', () {
    final state = GameState.seeded();

    expect(identical(RentSystem.accrue(state, 0), state), isTrue);
    expect(identical(RentSystem.accrue(state, -1), state), isTrue);
  });

  test('happiness and chaos thresholds select exact multipliers', () {
    final angry = _singleGhostState(
      kind: GhostKind.pocong,
      chaos: 0,
      eventHappinessModifier: -20,
    );
    final unhappy = _singleGhostState(kind: GhostKind.pocong, chaos: 29);
    final comfortable = _singleGhostState(
      kind: GhostKind.pocong,
      chaos: 30,
      eventHappinessModifier: 10,
    );
    final happy = _singleGhostState(
      kind: GhostKind.pocong,
      chaos: 70,
      eventHappinessModifier: 20,
      roomTagLevels: const {'quiet': 2},
    );

    expect(RentSystem.rentPerMinuteMicrocoinsFor(angry, 'resident'), 4000000);
    expect(RentSystem.rentPerMinuteMicrocoinsFor(unhappy, 'resident'), 7500000);
    expect(
      RentSystem.rentPerMinuteMicrocoinsFor(comfortable, 'resident'),
      11500000,
    );
    expect(RentSystem.rentPerMinuteMicrocoinsFor(happy, 'resident'), 18750000);
  });
}

GameState _singleGhostState({
  required GhostKind kind,
  required int chaos,
  int eventHappinessModifier = 0,
  int comfortLevel = 0,
  Map<String, int> roomTagLevels = const {},
}) => GameState(
  schemaVersion: GameState.currentSchemaVersion,
  walletCoins: 0,
  chaos: chaos,
  ghosts: [
    GhostState(
      id: 'resident',
      kind: kind,
      eventHappinessModifier: eventHappinessModifier,
    ),
  ],
  rooms: [
    RoomState(
      id: 'room_01',
      column: 0,
      occupantId: 'resident',
      upgrades: comfortLevel == 0
          ? const {}
          : {RoomAttribute.comfort: comfortLevel},
      roomTagLevels: roomTagLevels,
    ),
  ],
  complaintResolved: false,
);
