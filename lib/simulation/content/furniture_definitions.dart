import '../models/furniture_definition.dart';
import '../models/room.dart';

abstract final class FurnitureDefinitions {
  static const Map<String, FurnitureDefinition> all = {
    'bed': FurnitureDefinition(
      id: 'bed',
      slot: FurnitureSlot.primary,
      tags: ['quiet'],
    ),
    'reinforced_shelf': FurnitureDefinition(
      id: 'reinforced_shelf',
      slot: FurnitureSlot.primary,
      tags: ['sturdy'],
    ),
    'fan': FurnitureDefinition(
      id: 'fan',
      slot: FurnitureSlot.primary,
      tags: ['quiet'],
    ),
    'dresser': FurnitureDefinition(
      id: 'dresser',
      slot: FurnitureSlot.primary,
      tags: ['decorated'],
    ),
    'door': FurnitureDefinition(
      id: 'door',
      slot: FurnitureSlot.primary,
      tags: ['sturdy'],
    ),
    'lamp': FurnitureDefinition(
      id: 'lamp',
      slot: FurnitureSlot.primary,
      tags: ['shiny'],
    ),
    'plant': FurnitureDefinition(
      id: 'plant',
      slot: FurnitureSlot.decoration,
      tags: ['plant'],
    ),
    'lantern': FurnitureDefinition(
      id: 'lantern',
      slot: FurnitureSlot.decoration,
      tags: ['mystical'],
    ),
    'curtain': FurnitureDefinition(
      id: 'curtain',
      slot: FurnitureSlot.decoration,
      tags: ['quiet'],
    ),
    'rug': FurnitureDefinition(
      id: 'rug',
      slot: FurnitureSlot.decoration,
      tags: ['decorated'],
    ),
    'wall_charm': FurnitureDefinition(
      id: 'wall_charm',
      slot: FurnitureSlot.decoration,
      tags: ['mystical'],
    ),
    'shiny_trinket': FurnitureDefinition(
      id: 'shiny_trinket',
      slot: FurnitureSlot.decoration,
      tags: ['shiny'],
    ),
  };

  static FurnitureDefinition? byId(String id) => all[id];
}
