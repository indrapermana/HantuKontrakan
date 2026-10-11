class RoomState {
  const RoomState({required this.id, required this.column, this.occupantId});

  final String id;
  final int column;
  final String? occupantId;

  RoomState copyWith({required String? occupantId}) =>
      RoomState(id: id, column: column, occupantId: occupantId);

  Map<String, Object?> toJson() => {
    'id': id,
    'column': column,
    'occupantId': occupantId,
  };

  factory RoomState.fromJson(Map<String, Object?> json) => RoomState(
    id: json['id']! as String,
    column: json['column']! as int,
    occupantId: json['occupantId'] as String?,
  );
}
