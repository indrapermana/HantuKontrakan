enum RoomAttribute { comfort, silence, mysticalAffinity, durability }

enum FurnitureSlot { primary, decoration }

class RoomState {
  RoomState({
    required this.id,
    required this.column,
    this.row = 0,
    this.unlocked = true,
    this.occupantId,
    Map<RoomAttribute, int> upgrades = const {},
    Map<String, int> roomTagLevels = const {},
    Map<FurnitureSlot, String> furnitureIds = const {},
    Iterable<String> furnitureTags = const [],
  }) : upgrades = Map.unmodifiable(upgrades),
       roomTagLevels = Map.unmodifiable(roomTagLevels),
       furnitureIds = Map.unmodifiable(furnitureIds),
       furnitureTags = Set.unmodifiable(furnitureTags) {
    if (upgrades.values.any((level) => level < 0 || level > 2)) {
      throw ArgumentError.value(upgrades, 'upgrades', 'Levels must be 0–2.');
    }
    if (roomTagLevels.values.any((level) => level < 1 || level > 2)) {
      throw ArgumentError.value(
        roomTagLevels,
        'roomTagLevels',
        'Room tag levels must be 1 or 2.',
      );
    }
  }

  final String id;
  final int column;
  final int row;
  final bool unlocked;
  final String? occupantId;
  final Map<RoomAttribute, int> upgrades;
  final Map<String, int> roomTagLevels;
  final Map<FurnitureSlot, String> furnitureIds;
  final Set<String> furnitureTags;

  int levelFor(RoomAttribute attribute) => upgrades[attribute] ?? 0;
  String? furnitureIn(FurnitureSlot slot) => furnitureIds[slot];

  RoomState copyWith({
    required String? occupantId,
    bool? unlocked,
    Map<RoomAttribute, int>? upgrades,
    Map<String, int>? roomTagLevels,
    Map<FurnitureSlot, String>? furnitureIds,
    Iterable<String>? furnitureTags,
  }) => RoomState(
    id: id,
    column: column,
    row: row,
    unlocked: unlocked ?? this.unlocked,
    occupantId: occupantId,
    upgrades: upgrades ?? this.upgrades,
    roomTagLevels: roomTagLevels ?? this.roomTagLevels,
    furnitureIds: furnitureIds ?? this.furnitureIds,
    furnitureTags: furnitureTags ?? this.furnitureTags,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'column': column,
    'row': row,
    'unlocked': unlocked,
    'occupantId': occupantId,
    'upgrades': upgrades.map(
      (attribute, level) => MapEntry(attribute.name, level),
    ),
    'roomTagLevels': roomTagLevels,
    'furnitureIds': furnitureIds.map(
      (slot, furnitureId) => MapEntry(slot.name, furnitureId),
    ),
    'furnitureTags': furnitureTags.toList(growable: false),
  };

  factory RoomState.fromJson(Map<String, Object?> json) => RoomState(
    id: json['id']! as String,
    column: json['column']! as int,
    row: json['row'] as int? ?? 0,
    unlocked: json['unlocked'] as bool? ?? true,
    occupantId: json['occupantId'] as String?,
    upgrades: (json['upgrades'] as Map<String, Object?>? ?? const {}).map(
      (attribute, level) => MapEntry(
        RoomAttribute.values.firstWhere((value) => value.name == attribute),
        level! as int,
      ),
    ),
    roomTagLevels: (json['roomTagLevels'] as Map<String, Object?>? ?? const {})
        .map((tag, level) => MapEntry(tag, level! as int)),
    furnitureIds: (json['furnitureIds'] as Map<String, Object?>? ?? const {})
        .map(
          (slot, furnitureId) => MapEntry(
            FurnitureSlot.values.firstWhere((value) => value.name == slot),
            furnitureId! as String,
          ),
        ),
    furnitureTags: (json['furnitureTags'] as List<Object?>? ?? const [])
        .cast<String>(),
  );
}
