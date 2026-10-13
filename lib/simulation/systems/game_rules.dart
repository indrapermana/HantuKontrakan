import '../constants/game_balance.dart';
import '../content/furniture_definitions.dart';
import '../models/game_state.dart';
import '../models/room.dart';
import 'ability_system.dart';
import 'chaos_reputation_system.dart';
import 'event_modifier_system.dart';
import 'incident_system.dart';
import 'offline_earnings_system.dart';
import 'rent_system.dart';

enum ComplaintChoice { installSoundproofing, askTuyulToCalmDown, peaceOffering }

abstract final class GameRules {
  static GameState setGhostSpecialAction(
    GameState state,
    String ghostId,
    bool active,
  ) {
    if (!state.ghosts.any((ghost) => ghost.id == ghostId)) return state;
    final current = state.ghostById(ghostId);
    if (current.specialActionActive == active) return state;
    return state.copyWith(
      ghosts: state.ghosts
          .map(
            (ghost) => ghost.id == ghostId
                ? ghost.copyWith(specialActionActive: active)
                : ghost,
          )
          .toList(growable: false),
    );
  }

  static GameState advanceSimulation(
    GameState state,
    int seconds, {
    IncidentRandomSource incidentRandomSource =
        const SeededIncidentRandomSource(),
  }) {
    if (seconds <= 0) return state;
    var current = EventModifierSystem.expireDueModifiers(state);
    var remaining = seconds;
    while (remaining > 0) {
      final untilChaosTick =
          GameBalance.chaosIntervalSeconds -
          (current.activeSimulationSeconds % GameBalance.chaosIntervalSeconds);
      final untilAbility =
          AbilitySystem.secondsUntilNextTrigger(current) ?? remaining;
      final untilExpiry =
          EventModifierSystem.secondsUntilNextExpiry(current) ?? remaining;
      final untilIncidentCheck = IncidentSystem.secondsUntilNextCheck(current);
      final step = [
        remaining,
        untilChaosTick,
        untilAbility,
        untilExpiry,
        untilIncidentCheck,
      ].reduce((left, right) => left < right ? left : right);
      final previousActiveSeconds = current.activeSimulationSeconds;
      current = RentSystem.accrue(current, step);
      current = EventModifierSystem.expireDueModifiers(current);
      current = AbilitySystem.advanceActiveTime(current, step);
      current = ChaosReputationSystem.applyActiveTicks(
        current,
        previousActiveSeconds,
      );
      if (current.activeSimulationSeconds %
              GameBalance.incidentCheckIntervalSeconds ==
          0) {
        current = IncidentSystem.check(
          current,
          randomSource: incidentRandomSource,
        );
      }
      remaining -= step;
    }
    return current;
  }

  static GameState collectAllRent(GameState state, String claimId) {
    if (claimId.trim().isEmpty ||
        state.completedRentClaimIds.contains(claimId)) {
      return state;
    }
    final wholeCoins =
        state.pendingRentMicrocoins ~/ GameBalance.microcoinsPerCoin;
    if (wholeCoins <= 0) return state;
    return state.copyWith(
      walletCoins: state.walletCoins + wholeCoins,
      pendingRentMicrocoins:
          state.pendingRentMicrocoins % GameBalance.microcoinsPerCoin,
      completedRentClaimIds: {...state.completedRentClaimIds, claimId},
    );
  }

  static GameState resolveIncident(
    GameState state,
    String incidentId,
    String choiceId,
    String resolutionId,
  ) => IncidentSystem.resolve(state, incidentId, choiceId, resolutionId);

  static GameState pauseForOffline(GameState state, int timestampMillis) =>
      OfflineEarningsSystem.pause(state, timestampMillis);

  static GameState resumeFromOffline(GameState state, int timestampMillis) =>
      OfflineEarningsSystem.resume(state, timestampMillis);

  static GameState placeGhost(GameState state, String ghostId, String roomId) {
    if (!state.ghosts.any((ghost) => ghost.id == ghostId) ||
        state.roomForGhost(ghostId) != null) {
      return state;
    }
    final target = state.rooms.where((room) => room.id == roomId).firstOrNull;
    if (target == null || !target.unlocked || target.occupantId != null) {
      return state;
    }

    return state.copyWith(
      rooms: state.rooms
          .map(
            (room) =>
                room.id == roomId ? room.copyWith(occupantId: ghostId) : room,
          )
          .toList(growable: false),
    );
  }

  static GameState moveGhost(
    GameState state,
    String ghostId,
    String targetRoomId, {
    bool allowSwap = false,
  }) {
    final source = state.roomForGhost(ghostId);
    final target = state.rooms
        .where((room) => room.id == targetRoomId)
        .firstOrNull;
    if (source == null ||
        target == null ||
        !target.unlocked ||
        source.id == target.id) {
      return state;
    }

    final targetOccupantId = target.occupantId;
    if (targetOccupantId != null && !allowSwap) return state;

    return state.copyWith(
      rooms: state.rooms
          .map((room) {
            if (room.id == source.id) {
              return room.copyWith(occupantId: targetOccupantId);
            }
            if (room.id == target.id) {
              return room.copyWith(occupantId: ghostId);
            }
            return room;
          })
          .toList(growable: false),
    );
  }

  static GameState unlockRoom(GameState state, String roomId) {
    final room = state.rooms.where((room) => room.id == roomId).firstOrNull;
    final cost = GameBalance.roomUnlockCosts[roomId];
    final requiredLevel = GameBalance.roomUnlockLevels[roomId];
    if (room == null ||
        room.unlocked ||
        cost == null ||
        requiredLevel == null ||
        state.playerLevel < requiredLevel ||
        state.walletCoins < cost) {
      return state;
    }
    return state.copyWith(
      walletCoins: state.walletCoins - cost,
      rooms: state.rooms
          .map(
            (candidate) => candidate.id == roomId
                ? candidate.copyWith(
                    occupantId: candidate.occupantId,
                    unlocked: true,
                  )
                : candidate,
          )
          .toList(growable: false),
    );
  }

  static GameState upgradeRoom(
    GameState state,
    String roomId,
    RoomAttribute attribute,
  ) {
    final room = state.rooms.where((room) => room.id == roomId).firstOrNull;
    if (room == null || !room.unlocked) return state;
    final currentLevel = room.levelFor(attribute);
    final cost = GameBalance.roomUpgradeCosts[currentLevel];
    if (currentLevel >= GameBalance.maximumRoomUpgradeLevel ||
        cost == null ||
        state.walletCoins < cost) {
      return state;
    }
    final nextLevel = currentLevel + 1;
    final upgrades = Map<RoomAttribute, int>.of(room.upgrades)
      ..[attribute] = nextLevel;
    final tagLevels = Map<String, int>.of(room.roomTagLevels)
      ..[_tagFor(attribute)] = nextLevel;
    return state.copyWith(
      walletCoins: state.walletCoins - cost,
      rooms: state.rooms
          .map(
            (candidate) => candidate.id == roomId
                ? candidate.copyWith(
                    occupantId: candidate.occupantId,
                    upgrades: upgrades,
                    roomTagLevels: tagLevels,
                  )
                : candidate,
          )
          .toList(growable: false),
    );
  }

  static GameState equipFurniture(
    GameState state,
    String roomId,
    String furnitureId,
    FurnitureSlot slot,
  ) {
    final room = state.rooms.where((room) => room.id == roomId).firstOrNull;
    final furniture = FurnitureDefinitions.byId(furnitureId);
    if (room == null ||
        !room.unlocked ||
        furniture == null ||
        furniture.slot != slot ||
        room.furnitureIn(slot) == furnitureId) {
      return state;
    }
    final furnitureIds = Map<FurnitureSlot, String>.of(room.furnitureIds)
      ..[slot] = furnitureId;
    final tags = <String>{
      for (final id in furnitureIds.values)
        ...FurnitureDefinitions.byId(id)!.tags,
    };
    return state.copyWith(
      rooms: state.rooms
          .map(
            (candidate) => candidate.id == roomId
                ? candidate.copyWith(
                    occupantId: candidate.occupantId,
                    furnitureIds: furnitureIds,
                    furnitureTags: tags,
                  )
                : candidate,
          )
          .toList(growable: false),
    );
  }

  static String _tagFor(RoomAttribute attribute) => switch (attribute) {
    RoomAttribute.comfort => 'decorated',
    RoomAttribute.silence => 'quiet',
    RoomAttribute.mysticalAffinity => 'mystical',
    RoomAttribute.durability => 'sturdy',
  };

  static GameState resolveComplaint(
    GameState state,
    ComplaintChoice choice,
    String resolutionId,
  ) {
    if (state.complaintResolved || state.resolutionId == resolutionId) {
      return state;
    }

    final coinCost = switch (choice) {
      ComplaintChoice.installSoundproofing => GameBalance.soundproofingCoinCost,
      ComplaintChoice.askTuyulToCalmDown => 0,
      ComplaintChoice.peaceOffering => GameBalance.peaceOfferingCoinCost,
    };
    if (state.walletCoins < coinCost) return state;

    final pocongDelta = switch (choice) {
      ComplaintChoice.installSoundproofing =>
        GameBalance.soundproofingPocongHappiness,
      ComplaintChoice.askTuyulToCalmDown =>
        GameBalance.calmTuyulPocongHappiness,
      ComplaintChoice.peaceOffering => GameBalance.peaceOfferingHappiness,
    };
    final tuyulDelta = switch (choice) {
      ComplaintChoice.installSoundproofing => 0,
      ComplaintChoice.askTuyulToCalmDown => GameBalance.calmTuyulTuyulHappiness,
      ComplaintChoice.peaceOffering => GameBalance.peaceOfferingHappiness,
    };
    final ghosts = state.ghosts
        .map((ghost) {
          if (ghost.id == 'pocong_01' && pocongDelta != 0) {
            return ghost.copyWith(
              eventHappinessModifier: pocongDelta,
              eventModifierExpiresAtActiveSecond:
                  state.activeSimulationSeconds +
                  GameBalance.eventModifierDurationSeconds,
            );
          }
          if (ghost.id == 'tuyul_01' && tuyulDelta != 0) {
            return ghost.copyWith(
              eventHappinessModifier: tuyulDelta,
              eventModifierExpiresAtActiveSecond:
                  state.activeSimulationSeconds +
                  GameBalance.eventModifierDurationSeconds,
            );
          }
          return ghost;
        })
        .toList(growable: false);

    return state.copyWith(
      walletCoins: state.walletCoins - coinCost,
      ghosts: ghosts,
      complaintResolved: true,
      resolutionId: resolutionId,
    );
  }
}
