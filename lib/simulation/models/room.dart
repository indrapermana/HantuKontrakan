class RoomState {
  RoomState({
    required this.id,
    required this.column,
    this.row = 0,
    this.occupantId,
    Map<String, int> roomTagLevels = const {},
    Iterable<String> furnitureTags = const [],
  }) : roomTagLevels = Map.unmodifiable(roomTagLevels),
       furnitureTags = Set.unmodifiable(furnitureTags) {
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
  final String? occupantId;
  final Map<String, int> roomTagLevels;
  final Set<String> furnitureTags;

  RoomState copyWith({required String? occupantId}) => RoomState(
    id: id,
    column: column,
    row: row,
    occupantId: occupantId,
    roomTagLevels: roomTagLevels,
    furnitureTags: furnitureTags,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'column': column,
    'row': row,
    'occupantId': occupantId,
    'roomTagLevels': roomTagLevels,
    'furnitureTags': furnitureTags.toList(growable: false),
  };

  factory RoomState.fromJson(Map<String, Object?> json) => RoomState(
    id: json['id']! as String,
    column: json['column']! as int,
    row: json['row'] as int? ?? 0,
    occupantId: json['occupantId'] as String?,
    roomTagLevels: (json['roomTagLevels'] as Map<String, Object?>? ?? const {})
        .map((tag, level) => MapEntry(tag, level! as int)),
    furnitureTags: (json['furnitureTags'] as List<Object?>? ?? const [])
        .cast<String>(),
  );
}
