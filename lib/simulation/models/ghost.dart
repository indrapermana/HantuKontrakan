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
  static const Object _notProvided = Object();

  const GhostState({
    required this.id,
    required this.kind,
    this.eventHappinessModifier = 0,
    this.eventModifierExpiresAtActiveSecond,
    this.specialActionActive = false,
  });

  final String id;
  final GhostKind kind;
  final int eventHappinessModifier;
  final int? eventModifierExpiresAtActiveSecond;
  final bool specialActionActive;

  GhostState copyWith({
    int? eventHappinessModifier,
    Object? eventModifierExpiresAtActiveSecond = _notProvided,
    bool? specialActionActive,
  }) => GhostState(
    id: id,
    kind: kind,
    eventHappinessModifier:
        eventHappinessModifier ?? this.eventHappinessModifier,
    eventModifierExpiresAtActiveSecond:
        identical(eventModifierExpiresAtActiveSecond, _notProvided)
        ? this.eventModifierExpiresAtActiveSecond
        : eventModifierExpiresAtActiveSecond as int?,
    specialActionActive: specialActionActive ?? this.specialActionActive,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'eventHappinessModifier': eventHappinessModifier,
    'eventModifierExpiresAtActiveSecond': eventModifierExpiresAtActiveSecond,
    'specialActionActive': specialActionActive,
  };

  factory GhostState.fromJson(Map<String, Object?> json) => GhostState(
    id: json['id']! as String,
    kind: GhostKind.fromName(json['kind']! as String),
    eventHappinessModifier: json['eventHappinessModifier']! as int,
    eventModifierExpiresAtActiveSecond:
        json['eventModifierExpiresAtActiveSecond'] as int?,
    specialActionActive: json['specialActionActive'] as bool? ?? false,
  );
}
