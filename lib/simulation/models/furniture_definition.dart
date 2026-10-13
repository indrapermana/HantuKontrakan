import 'room.dart';

class FurnitureDefinition {
  const FurnitureDefinition({
    required this.id,
    required this.slot,
    required this.tags,
  });

  final String id;
  final FurnitureSlot slot;
  final List<String> tags;
}
