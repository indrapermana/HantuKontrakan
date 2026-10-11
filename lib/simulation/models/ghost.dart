enum GhostKind {
  pocong('Pocong', 'Pelompat yang gelisah'),
  tuyul('Tuyul', 'Pengumpul yang usil');

  const GhostKind(this.displayName, this.archetype);

  final String displayName;
  final String archetype;

  static GhostKind fromName(String value) =>
      GhostKind.values.firstWhere((kind) => kind.name == value);
}

class GhostState {
  const GhostState({
    required this.id,
    required this.kind,
    this.eventHappinessModifier = 0,
  });

  final String id;
  final GhostKind kind;
  final int eventHappinessModifier;

  GhostState copyWith({int? eventHappinessModifier}) => GhostState(
    id: id,
    kind: kind,
    eventHappinessModifier:
        eventHappinessModifier ?? this.eventHappinessModifier,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'kind': kind.name,
    'eventHappinessModifier': eventHappinessModifier,
  };

  factory GhostState.fromJson(Map<String, Object?> json) => GhostState(
    id: json['id']! as String,
    kind: GhostKind.fromName(json['kind']! as String),
    eventHappinessModifier: json['eventHappinessModifier']! as int,
  );
}
