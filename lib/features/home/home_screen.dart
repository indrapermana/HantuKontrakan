import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../features/debug/debug_hud.dart';
import '../../game/hantu_game.dart';
import '../../l10n/app_localizations.dart';
import '../../simulation/constants/game_balance.dart';
import '../../simulation/content/incident_definitions.dart';
import '../../simulation/content/progression_definitions.dart';
import '../../simulation/models/incident_definition.dart';
import '../../simulation/systems/game_rules.dart';
import '../tutorial/tutorial_panel.dart';
import '../missions/mission_dialog.dart';
import 'detail_sheets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final strings = AppLocalizations.of(context);
        if (!controller.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final state = controller.state;
        final activeIncident = state.activeIncidentId == null
            ? null
            : IncidentDefinitions.byId(state.activeIncidentId!);
        final pocongHappiness = controller.happinessFor('pocong_01');
        return Scaffold(
          appBar: AppBar(
            title: Text(strings.appTitleUppercase),
            centerTitle: true,
            actions: [
              IconButton(
                key: const Key('language-button'),
                tooltip: strings.languageTitle,
                onPressed: () => _showLanguagePicker(context),
                icon: const Icon(Icons.language),
              ),
              IconButton(
                key: const Key('missions-button'),
                tooltip: strings.missionsTitle,
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => MissionDialog(controller: controller),
                ),
                icon: const Icon(Icons.assignment_turned_in),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        strings.spiritCoins(state.walletCoins),
                        key: const Key('wallet-coins'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        strings.mysticalCrystals(state.mysticalCrystals),
                        key: const Key('mystical-crystals'),
                      ),
                      const Spacer(),
                      Text(
                        strings.ghostHappinessSummary(
                          'Pocong',
                          pocongHappiness,
                        ),
                      ),
                    ],
                  ),
                ),
                if (kDebugMode) DebugHud(controller: controller),
                TutorialPanel(
                  step: state.tutorialStep,
                  onContinue: controller.continueTutorial,
                  onPlacePocong: () =>
                      controller.placeGhost('pocong_01', 'room_01'),
                  onPlaceKuntilanak: () =>
                      controller.placeGhost('kuntilanak_01', 'room_02'),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GameWidget(
                      key: ValueKey(controller.revision),
                      game: HantuGame(
                        state: state,
                        onRoomTap: (roomId) =>
                            _showRoomDetails(context, roomId),
                        onGhostTap: (ghostId) =>
                            _showGhostProfile(context, ghostId),
                        roomLabelFor: (roomId) =>
                            strings.roomTitle(_roomNumber(roomId)),
                        happinessLabelFor: strings.roomCanvasHappiness,
                        lockedLabel: strings.roomCanvasLocked,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('collect-rent'),
                          onPressed: controller.pendingRentCoins > 0
                              ? () => controller.collectAllRent()
                              : null,
                          icon: const Icon(Icons.savings),
                          label: Text(
                            strings.collectAllRent(controller.pendingRentCoins),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (activeIncident != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const Key('incident-button'),
                            onPressed: () =>
                                _showIncident(context, activeIncident),
                            icon: const Icon(Icons.crisis_alert),
                            label: Text(
                              strings.activeIncident(
                                _localized(context, activeIncident.title!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('complaint-button'),
                          onPressed: controller.hasPendingComplaint
                              ? () => _showComplaint(context)
                              : null,
                          icon: Icon(
                            controller.hasPendingComplaint
                                ? Icons.campaign
                                : Icons.check_circle,
                          ),
                          label: Text(
                            controller.hasPendingComplaint
                                ? strings.pendingComplaint
                                : strings.resolvedComplaint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRoomDetails(BuildContext context, String roomId) async {
    final strings = AppLocalizations.of(context);
    final room = controller.state.rooms
        .where((candidate) => candidate.id == roomId)
        .firstOrNull;
    if (room == null || !room.unlocked) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.roomTitle(_roomNumber(roomId)),
                key: Key('selected-$roomId'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                strings.roomLocked,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                room == null
                    ? strings.roomUnlockLater
                    : strings.roomUnlockRequirement(
                        GameBalance.roomUnlockCosts[room.id]!,
                        ProgressionDefinitions.requiredLevelForRoom(room.id),
                      ),
              ),
              if (room != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: Key('unlock-${room.id}'),
                    onPressed:
                        controller.state.playerLevel >=
                                ProgressionDefinitions.requiredLevelForRoom(
                                  room.id,
                                ) &&
                            controller.state.walletCoins >=
                                GameBalance.roomUnlockCosts[room.id]!
                        ? () async {
                            Navigator.pop(context);
                            await controller.unlockRoom(room.id);
                          }
                        : null,
                    child: Text(strings.unlockRoom),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
      return;
    }
    final ghost = room.occupantId == null
        ? null
        : controller.state.ghostById(room.occupantId!);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => RoomDetailsSheet(
        state: controller.state,
        room: room,
        onViewGhost: ghost == null
            ? () {}
            : () async {
                Navigator.pop(sheetContext);
                await _showGhostProfile(context, ghost.id);
              },
        onMoveGhost: ghost == null
            ? () {}
            : () async {
                Navigator.pop(sheetContext);
                await _chooseDestination(context, ghost.id, room.id);
              },
        onUpgrade: (attribute) async {
          Navigator.pop(sheetContext);
          await controller.upgradeRoom(room.id, attribute);
        },
        onEquipFurniture: (slot, furnitureId) async {
          Navigator.pop(sheetContext);
          await controller.equipFurniture(room.id, furnitureId, slot);
        },
        onRepair: () async {
          Navigator.pop(sheetContext);
          await controller.repairRoom(room.id);
        },
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final languageCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(strings.languageTitle),
        children: [
          SimpleDialogOption(
            key: const Key('language-id'),
            onPressed: () => Navigator.pop(dialogContext, 'id'),
            child: Text(strings.languageIndonesian),
          ),
          SimpleDialogOption(
            key: const Key('language-en'),
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: Text(strings.languageEnglish),
          ),
        ],
      ),
    );
    if (languageCode != null) {
      await controller.setLanguageCode(languageCode);
    }
  }

  Future<void> _showGhostProfile(BuildContext context, String ghostId) async {
    final ghost = controller.state.ghosts
        .where((candidate) => candidate.id == ghostId)
        .firstOrNull;
    if (ghost == null) return;
    final room = controller.state.roomForGhost(ghostId);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => GhostProfileSheet(
        state: controller.state,
        ghost: ghost,
        onMoveGhost: room == null
            ? () {}
            : () async {
                Navigator.pop(sheetContext);
                await _chooseDestination(context, ghost.id, room.id);
              },
      ),
    );
  }

  Future<void> _chooseDestination(
    BuildContext context,
    String ghostId,
    String sourceRoomId,
  ) async {
    final strings = AppLocalizations.of(context);
    final destinations = controller.state.rooms
        .where((room) => room.unlocked && room.id != sourceRoomId)
        .toList(growable: false);
    if (destinations.isEmpty) return;

    final targetRoomId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(strings.chooseDestination),
        children: [
          for (final room in destinations)
            SimpleDialogOption(
              key: Key('destination-${room.id}'),
              onPressed: () => Navigator.pop(context, room.id),
              child: Text(
                room.occupantId == null
                    ? strings.vacantRoom(_roomNumber(room.id))
                    : strings.occupiedRoom(_roomNumber(room.id)),
              ),
            ),
        ],
      ),
    );
    if (targetRoomId == null || !context.mounted) return;

    final target = controller.state.roomById(targetRoomId);
    if (target.occupantId == null) {
      await controller.moveGhost(ghostId, targetRoomId);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmSwapTitle),
        content: Text(strings.confirmSwapBody(_roomNumber(targetRoomId))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-swap'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.confirmSwap),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.moveGhost(ghostId, targetRoomId, allowSwap: true);
  }

  String _roomNumber(String roomId) => roomId.split('_').last;

  Future<void> _showIncident(
    BuildContext context,
    IncidentDefinition incident,
  ) async {
    final strings = AppLocalizations.of(context);
    final choice = await showDialog<IncidentChoiceDefinition>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_localized(context, incident.title!)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_localized(context, incident.dialogue!)),
              const SizedBox(height: 16),
              for (final choice in incident.choices) ...[
                OutlinedButton(
                  key: Key('incident-choice-${choice.id}'),
                  onPressed:
                      controller.state.walletCoins + choice.effects.coinDelta >=
                          0
                      ? () => Navigator.pop(dialogContext, choice)
                      : null,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '${_localized(context, choice.label)}\n'
                        '${strings.incidentConsequencePreview(_effectPreview(context, choice.effects))}'
                        '${controller.state.walletCoins + choice.effects.coinDelta < 0 ? '\n${strings.incidentNotEnoughCoins}' : ''}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;

    final committed = await controller.resolveIncident(incident.id, choice.id);
    if (!committed || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.incidentResolvedTitle),
        content: Text(
          '${_localized(context, choice.response)}\n\n'
          '${strings.incidentConsequencePreview(_effectPreview(context, choice.effects))}',
        ),
        actions: [
          FilledButton(
            key: const Key('incident-outcome-continue'),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.continueLabel),
          ),
        ],
      ),
    );
  }

  String _localized(BuildContext context, LocalizedIncidentText text) =>
      Localizations.localeOf(context).languageCode == 'id' ? text.id : text.en;

  String _effectPreview(BuildContext context, IncidentEffects effects) {
    final strings = AppLocalizations.of(context);
    final parts = <String>[];
    if (effects.coinDelta != 0) {
      parts.add(strings.incidentEffectCoins(_signed(effects.coinDelta)));
    }
    final happinessEntries = effects.happinessDeltaByKind.entries.toList()
      ..sort((left, right) => left.key.index.compareTo(right.key.index));
    for (final entry in happinessEntries) {
      parts.add(
        strings.incidentEffectHappiness(
          entry.key.displayName,
          _signed(entry.value),
        ),
      );
    }
    if (effects.chaosDelta != 0) {
      parts.add(strings.incidentEffectChaos(_signed(effects.chaosDelta)));
    }
    if (effects.reputationDelta != 0) {
      parts.add(
        strings.incidentEffectReputation(_signed(effects.reputationDelta)),
      );
    }
    return parts.join(', ');
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';

  Future<void> _showComplaint(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final choice = await showDialog<ComplaintChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.complaintTitle),
        content: Text(strings.complaintBody),
        actions: [
          _ChoiceButton(
            key: const Key('choice-soundproof'),
            title: strings.installSoundproofing,
            effect: strings.soundproofingEffect,
            onPressed: () =>
                Navigator.pop(context, ComplaintChoice.installSoundproofing),
          ),
          _ChoiceButton(
            title: strings.askTuyulCalm,
            effect: strings.askTuyulCalmEffect,
            onPressed: () =>
                Navigator.pop(context, ComplaintChoice.askTuyulToCalmDown),
          ),
          _ChoiceButton(
            title: strings.peaceOffering,
            effect: strings.peaceOfferingEffect,
            onPressed: () =>
                Navigator.pop(context, ComplaintChoice.peaceOffering),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    await controller.resolveComplaint(choice);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          strings.complaintResolvedMessage(
            controller.happinessFor('pocong_01'),
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.title,
    required this.effect,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String effect;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('$title\n$effect'),
      ),
    ),
  );
}
