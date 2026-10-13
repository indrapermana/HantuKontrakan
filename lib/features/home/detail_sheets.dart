import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../simulation/content/ghost_definitions.dart';
import '../../simulation/models/game_state.dart';
import '../../simulation/models/ghost.dart';
import '../../simulation/models/room.dart';
import '../../simulation/systems/happiness_system.dart';

class RoomDetailsSheet extends StatelessWidget {
  const RoomDetailsSheet({
    required this.state,
    required this.room,
    required this.onViewGhost,
    required this.onMoveGhost,
    super.key,
  });

  final GameState state;
  final RoomState room;
  final VoidCallback onViewGhost;
  final VoidCallback onMoveGhost;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final occupantId = room.occupantId;
    final ghost = occupantId == null ? null : state.ghostById(occupantId);
    final breakdown = occupantId == null
        ? null
        : HappinessSystem.breakdownFor(state, occupantId);
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
            Text(strings.likes(definition.preferredRoomTags.join(', '))),
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
    'Senang' => strings.moodHappy,
    'Nyaman' => strings.moodComfortable,
    'Tidak senang' => strings.moodUnhappy,
    _ => strings.moodAngry,
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
