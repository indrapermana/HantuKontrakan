import '../content/furniture_definitions.dart';
import '../content/property_definitions.dart';
import '../models/game_state.dart';
import '../models/ghost.dart';
import '../models/room.dart';

abstract final class PortfolioSystem {
  static const premiumFurnitureCrystalCosts = <String, int>{
    'moon_mirror': 3,
    'spirit_radio': 5,
  };

  static bool canUnlockSecondProperty(GameState state) {
    final firstRooms =
        state.propertyRoomsById[PropertyDefinitions.firstPropertyId];
    return firstRooms != null &&
        firstRooms.length == 4 &&
        firstRooms.every((room) => room.unlocked && room.occupantId != null);
  }

  static GameState unlockSecondProperty(GameState state) {
    if (state.propertyRoomsById.containsKey(
          PropertyDefinitions.secondPropertyId,
        ) ||
        !canUnlockSecondProperty(state)) {
      return state;
    }
    final rooms = <String, List<RoomState>>{
      ...state.propertyRoomsById,
      PropertyDefinitions.secondPropertyId:
          PropertyDefinitions.secondPropertyRooms(),
    };
    final ghosts = state.ghosts.any((ghost) => ghost.id == 'pocong_02')
        ? state.ghosts
        : [
            ...state.ghosts,
            const GhostState(id: 'pocong_02', kind: GhostKind.pocong),
          ];
    return state.copyWith(propertyRoomsById: rooms, ghosts: ghosts);
  }

  static GameState switchProperty(GameState state, String propertyId) {
    if (propertyId == state.activePropertyId ||
        !state.propertyRoomsById.containsKey(propertyId)) {
      return state;
    }
    return state.copyWith(activePropertyId: propertyId);
  }

  static GameState purchaseFurniture(GameState state, String furnitureId) {
    final cost = premiumFurnitureCrystalCosts[furnitureId];
    if (cost == null ||
        FurnitureDefinitions.byId(furnitureId) == null ||
        state.ownedFurnitureIds.contains(furnitureId) ||
        state.mysticalCrystals < cost) {
      return state;
    }
    return state.copyWith(
      mysticalCrystals: state.mysticalCrystals - cost,
      ownedFurnitureIds: {...state.ownedFurnitureIds, furnitureId},
    );
  }

  static GameState completeGhostStory(GameState state, String ghostId) {
    if (state.completedGhostStoryIds.contains(ghostId) ||
        !state.ghosts.any((ghost) => ghost.id == ghostId) ||
        state.roomForGhost(ghostId) == null) {
      return state;
    }
    return state.copyWith(
      completedGhostStoryIds: {...state.completedGhostStoryIds, ghostId},
    );
  }
}
