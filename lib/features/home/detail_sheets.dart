import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../simulation/constants/game_balance.dart';
import '../../simulation/content/furniture_definitions.dart';
import '../../simulation/content/ghost_definitions.dart';
import '../../simulation/models/game_state.dart';
import '../../simulation/models/ghost.dart';
import '../../simulation/models/room.dart';
import '../../simulation/systems/happiness_system.dart';
import '../../simulation/systems/repair_system.dart';

class RoomDetailsSheet extends StatelessWidget {
  const RoomDetailsSheet({
    required this.state,
    required this.room,
    required this.onViewGhost,
    required this.onMoveGhost,
    required this.onUpgrade,
    required this.onEquipFurniture,
    this.onRepair,
    super.key,
  });

  final GameState state;
  final RoomState room;
  final VoidCallback onViewGhost;
  final VoidCallback onMoveGhost;
  final ValueChanged<RoomAttribute> onUpgrade;
  final void Function(FurnitureSlot slot, String furnitureId) onEquipFurniture;
  final VoidCallback? onRepair;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final occupantId = room.occupantId;
    final ghost = occupantId == null ? null : state.ghostById(occupantId);
    final breakdown = occupantId == null
        ? null
        : HappinessSystem.breakdownFor(state, occupantId);
    final repairCost = RepairSystem.costFor(state, room.id);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.roomTitle(_roomNumber(room.id)),
              key: Key('selected-${room.id}'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              ghost == null
                  ? strings.vacantTenant
                  : strings.tenantLabel(ghost.kind.displayName),
              key: const Key('room-tenant'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (ghost != null && breakdown != null) ...[
              const SizedBox(height: 8),
              Text(
                strings.happinessDetail(
                  breakdown.total,
                  localizedMood(strings, breakdown.total),
                ),
                key: const Key('room-happiness'),
              ),
              const SizedBox(height: 12),
              Text(
                strings.happinessBreakdownTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              _BreakdownRows(breakdown: breakdown),
            ],
            const SizedBox(height: 16),
            Text(
              strings.roomUpgrades,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final attribute in RoomAttribute.values)
              _UpgradeRow(
                room: room,
                attribute: attribute,
                walletCoins: state.walletCoins,
                onUpgrade: onUpgrade,
              ),
            if (room.repairRequired) ...[
              const SizedBox(height: 12),
              Text(
                strings.repairRequired,
                key: const Key('repair-required'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('repair-room'),
                  onPressed: onRepair != null && state.walletCoins >= repairCost
                      ? onRepair
                      : null,
                  icon: const Icon(Icons.handyman),
                  label: Text(strings.repairRoom(repairCost)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              strings.furnitureSlots,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final slot in FurnitureSlot.values)
              _FurnitureRow(room: room, slot: slot, onEquip: onEquipFurniture),
            if (ghost != null && breakdown != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('view-ghost-profile'),
                  onPressed: onViewGhost,
                  icon: const Icon(Icons.person_search),
                  label: Text(strings.viewGhostProfile),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('move-tenant'),
                  onPressed: onMoveGhost,
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(strings.moveTenant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({
    required this.room,
    required this.attribute,
    required this.walletCoins,
    required this.onUpgrade,
  });

  final RoomState room;
  final RoomAttribute attribute;
  final int walletCoins;
  final ValueChanged<RoomAttribute> onUpgrade;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final level = room.levelFor(attribute);
    final cost = GameBalance.roomUpgradeCosts[level];
    final enabled =
        level < GameBalance.maximumRoomUpgradeLevel &&
        cost != null &&
        walletCoins >= cost;
    return Row(
      children: [
        Expanded(
          child: Text('${_attributeName(strings, attribute)}  $level/2'),
        ),
        TextButton(
          key: Key('upgrade-${attribute.name}'),
          onPressed: enabled ? () => onUpgrade(attribute) : null,
          child: Text(
            level >= GameBalance.maximumRoomUpgradeLevel
                ? strings.maximumLevel
                : strings.upgradeCost(cost!),
          ),
        ),
      ],
    );
  }
}

class _FurnitureRow extends StatelessWidget {
  const _FurnitureRow({
    required this.room,
    required this.slot,
    required this.onEquip,
  });

  final RoomState room;
  final FurnitureSlot slot;
  final void Function(FurnitureSlot slot, String furnitureId) onEquip;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final current = room.furnitureIn(slot);
    final choices = FurnitureDefinitions.all.values
        .where((item) => item.slot == slot)
        .toList(growable: false);
    return Row(
      children: [
        Expanded(
          child: Text(
            strings.furnitureSlotValue(
              _slotName(strings, slot),
              current == null
                  ? strings.emptySlot
                  : localizedFurniture(strings, current),
            ),
          ),
        ),
        PopupMenuButton<String>(
          key: Key('furniture-${slot.name}'),
          tooltip: strings.chooseFurniture,
          onSelected: (id) => onEquip(slot, id),
          itemBuilder: (context) => [
            for (final item in choices)
              PopupMenuItem(
                value: item.id,
                child: Text(localizedFurniture(strings, item.id)),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(strings.chooseFurniture),
          ),
        ),
      ],
    );
  }
}

class GhostProfileSheet extends StatelessWidget {
  const GhostProfileSheet({
    required this.state,
    required this.ghost,
    required this.onMoveGhost,
    super.key,
  });

  final GameState state;
  final GhostState ghost;
  final VoidCallback onMoveGhost;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final definition = GhostDefinitions.byKind(ghost.kind);
    final room = state.roomForGhost(ghost.id);
    final breakdown = HappinessSystem.breakdownFor(state, ghost.id);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(_ghostIcon(ghost.kind), size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.ghostProfileTitle(ghost.kind.displayName),
                        key: Key('ghost-profile-${ghost.id}'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(localizedArchetype(strings, ghost.kind)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              strings.happinessDetail(
                breakdown.total,
                localizedMood(strings, breakdown.total),
              ),
              key: const Key('ghost-happiness'),
            ),
            Text(
              room == null
                  ? strings.unassignedGhost
                  : strings.currentRoom(_roomNumber(room.id)),
              key: const Key('ghost-room'),
            ),
            Text(strings.baseRent(definition.baseRentPerMinute)),
            Text(
              strings.likes(
                definition.preferredRoomTags
                    .map((tag) => localizedTag(strings, tag))
                    .join(', '),
              ),
            ),
            Text(strings.dislikes(definition.dislikedNeighbor.displayName)),
            Text(
              strings.ability(localizedAbility(strings, definition.abilityId)),
            ),
            const SizedBox(height: 12),
            Text(
              strings.happinessBreakdownTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            _BreakdownRows(breakdown: breakdown),
            if (room != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('profile-move-tenant'),
                  onPressed: onMoveGhost,
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(strings.moveTenant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownRows extends StatelessWidget {
  const _BreakdownRows({required this.breakdown});

  final HappinessBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final values = [
      (strings.baseHappinessLabel, breakdown.base),
      (strings.roomPreferenceLabel, breakdown.roomPreference),
      (strings.furniturePreferenceLabel, breakdown.furniturePreference),
      (strings.neighborLabel, breakdown.compatibility),
      (strings.eventLabel, breakdown.event),
    ];
    return Column(
      key: const Key('happiness-breakdown'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final value in values)
          Text(strings.happinessComponent(value.$1, value.$2)),
      ],
    );
  }
}

String localizedMood(AppLocalizations strings, int happiness) {
  final mood = HappinessSystem.moodFor(happiness);
  return switch (mood) {
    HappinessMood.happy => strings.moodHappy,
    HappinessMood.comfortable => strings.moodComfortable,
    HappinessMood.unhappy => strings.moodUnhappy,
    HappinessMood.angry => strings.moodAngry,
  };
}

String localizedArchetype(AppLocalizations strings, GhostKind kind) =>
    switch (kind) {
      GhostKind.pocong => strings.archetypePocong,
      GhostKind.kuntilanak => strings.archetypeKuntilanak,
      GhostKind.tuyul => strings.archetypeTuyul,
      GhostKind.genderuwo => strings.archetypeGenderuwo,
    };

String localizedAbility(AppLocalizations strings, String abilityId) =>
    switch (abilityId) {
      'lost_coins' => strings.abilityLostCoins,
      'neighborhood_reputation' => strings.abilityNeighborhoodReputation,
      'base_rent_bonus' => strings.abilityBaseRentBonus,
      'repair_discount' => strings.abilityRepairDiscount,
      _ => abilityId,
    };

IconData _ghostIcon(GhostKind kind) => switch (kind) {
  GhostKind.pocong => Icons.airline_seat_flat,
  GhostKind.kuntilanak => Icons.face_3,
  GhostKind.tuyul => Icons.savings,
  GhostKind.genderuwo => Icons.forest,
};

String _roomNumber(String roomId) => roomId.split('_').last;

String _attributeName(AppLocalizations strings, RoomAttribute attribute) =>
    switch (attribute) {
      RoomAttribute.comfort => strings.comfortAttribute,
      RoomAttribute.silence => strings.silenceAttribute,
      RoomAttribute.mysticalAffinity => strings.mysticalAttribute,
      RoomAttribute.durability => strings.durabilityAttribute,
    };

String _slotName(AppLocalizations strings, FurnitureSlot slot) =>
    switch (slot) {
      FurnitureSlot.primary => strings.primarySlot,
      FurnitureSlot.decoration => strings.decorationSlot,
    };

String localizedTag(AppLocalizations strings, String tag) => switch (tag) {
  'quiet' => strings.tagQuiet,
  'plant' => strings.tagPlant,
  'decorated' => strings.tagDecorated,
  'mystical' => strings.tagMystical,
  'shiny' => strings.tagShiny,
  'sturdy' => strings.tagSturdy,
  _ => throw ArgumentError.value(tag, 'tag', 'Missing localization'),
};

String localizedFurniture(AppLocalizations strings, String id) => switch (id) {
  'bed' => strings.furnitureBed,
  'reinforced_shelf' => strings.furnitureReinforcedShelf,
  'fan' => strings.furnitureFan,
  'dresser' => strings.furnitureDresser,
  'door' => strings.furnitureDoor,
  'lamp' => strings.furnitureLamp,
  'plant' => strings.furniturePlant,
  'lantern' => strings.furnitureLantern,
  'curtain' => strings.furnitureCurtain,
  'rug' => strings.furnitureRug,
  'wall_charm' => strings.furnitureWallCharm,
  'shiny_trinket' => strings.furnitureShinyTrinket,
  _ => throw ArgumentError.value(id, 'id', 'Missing localization'),
};
