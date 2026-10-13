enum GhostKind {
  pocong('Pocong', 'Pelompat yang gelisah'),
  kuntilanak('Kuntilanak', 'Tetangga yang dramatis'),
  tuyul('Tuyul', 'Pengumpul yang usil'),
  genderuwo('Genderuwo', 'Raksasa yang lembut');

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
    this.specialActionActive = false,
  });

  final String id;
  final GhostKind kind;
  final int eventHappinessModifier;
  final bool specialActionActive;

  GhostState copyWith({
    int? eventHappinessModifier,
    bool? specialActionActive,
  }) => GhostState(
    id: id,
    kind: kind,
    eventHappinessModifier:
        eventHappinessModifier ?? this.eventHappinessModifier,
    specialActionActive: specialActionActive ?? this.specialActionActive,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'kind': kind.name,
    'eventHappinessModifier': eventHappinessModifier,
    'specialActionActive': specialActionActive,
  };

  factory GhostState.fromJson(Map<String, Object?> json) => GhostState(
    id: json['id']! as String,
    kind: GhostKind.fromName(json['kind']! as String),
    eventHappinessModifier: json['eventHappinessModifier']! as int,
    specialActionActive: json['specialActionActive'] as bool? ?? false,
  );
}
