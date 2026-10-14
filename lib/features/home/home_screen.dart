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
import '../../widgets/game_panel.dart';
import '../missions/mission_dialog.dart';
import '../settings/audio_settings_dialog.dart';
import '../tutorial/tutorial_panel.dart';
import 'detail_sheets.dart';
import 'home_game_shell.dart';

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
        final offlineEarningsCoins = controller
            .takePendingOfflineEarningsCoins();
        if (offlineEarningsCoins > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _showOfflineReturn(context, offlineEarningsCoins);
            }
          });
        }
        final activeIncident = state.activeIncidentId == null
            ? null
            : IncidentDefinitions.byId(state.activeIncidentId!);
        final pocongHappiness = controller.happinessFor('pocong_01');
        final currentLevel = ProgressionDefinitions.byLevel(state.playerLevel);
        final nextLevel =
            state.playerLevel >= ProgressionDefinitions.levels.length
            ? null
            : ProgressionDefinitions.byLevel(state.playerLevel + 1);
        final levelProgress = nextLevel == null
            ? 1.0
            : (state.playerExperience - currentLevel.requiredExperience) /
                  (nextLevel.requiredExperience -
                      currentLevel.requiredExperience);
        return Scaffold(
          backgroundColor: const Color(0xFF111631),
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox.expand(
                key: const Key('full-screen-game'),
                child: GameWidget(
                  key: ValueKey(controller.revision),
                  loadingBuilder: (context) => const ColoredBox(
                    key: Key('game-loading'),
                    color: Color(0xFF111631),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  game: HantuGame(
                    state: state,
                    onRoomTap: (roomId) => _showRoomDetails(context, roomId),
                    onGhostTap: (ghostId) =>
                        _showGhostProfile(context, ghostId),
                    roomLabelFor: (roomId) =>
                        strings.roomTitle(_roomNumber(roomId)),
                    happinessLabelFor: strings.roomCanvasHappiness,
                    lockedLabel: strings.roomCanvasLocked,
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: HomeGameHud(
                    levelLabel: 'Lv. ${state.playerLevel}',
                    experienceProgress: levelProgress,
                    coinLabel: strings.spiritCoins(state.walletCoins),
                    crystalLabel: strings.mysticalCrystals(
                      state.mysticalCrystals,
                    ),
                    happinessLabel: strings.ghostHappinessSummary(
                      'Pocong',
                      pocongHappiness,
                    ),
                    settingsTooltip: strings.settingsTitle,
                    languageTooltip: strings.languageTitle,
                    onSettings: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          AudioSettingsDialog(controller: controller),
                    ),
                    onLanguage: () => _showLanguagePicker(context),
                  ),
                ),
              ),
              if (kDebugMode)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 92),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: DebugHud(controller: controller),
                    ),
                  ),
                ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(top: kDebugMode ? 142 : 94),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TutorialPanel(
                      step: state.tutorialStep,
                      onContinue: controller.continueTutorial,
                      onPlacePocong: () =>
                          controller.placeGhost('pocong_01', 'room_01'),
                      onPlaceKuntilanak: () =>
                          controller.placeGhost('kuntilanak_01', 'room_02'),
                    ),
                  ),
                ),
              ),
              WorldActionOverlay(
                collectLabel: strings.collectAllRent(
                  controller.pendingRentCoins,
                ),
                canCollect: controller.pendingRentCoins > 0,
                onCollect: controller.collectAllRent,
                complaintLabel: controller.hasPendingComplaint
                    ? strings.pendingComplaint
                    : strings.resolvedComplaint,
                hasComplaint: controller.hasPendingComplaint,
                onComplaint: () => _showComplaint(context),
                incidentLabel: activeIncident == null
                    ? null
                    : strings.activeIncident(
                        _localized(context, activeIncident.title!),
                      ),
                onIncident: activeIncident == null
                    ? null
                    : () => _showIncident(context, activeIncident),
                moreTooltip: strings.moreActionsLabel,
                onMore: () => _showActionCenter(context),
              ),
              HomeBottomNavigation(
                homeLabel: strings.navigationHome,
                missionsLabel: strings.missionsTitle,
                ghostsLabel: strings.navigationGhosts,
                shopLabel: strings.navigationShop,
                onMissions: () => showDialog<void>(
                  context: context,
                  builder: (_) => MissionDialog(controller: controller),
                ),
                onGhosts: () => _showGhostRoster(context),
                onShop: () => _showPropertyActions(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showActionCenter(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        title: strings.moreActionsLabel,
        icon: Icons.auto_awesome_motion_rounded,
        // ignore: sort_child_properties_last
        child: GameChoiceCard(
          key: const Key('collect-rent-rewarded'),
          title: controller.rewardedRentBonusesRemaining == 0
              ? strings.rewardedRentDailyLimit
              : strings.rewardedRentButton(
                  controller.pendingRentCoins,
                  controller.rewardedRentBonusesRemaining,
                ),
          subtitle: '',
          enabled: controller.canCollectRewardedRent,
          leading: const Icon(
            Icons.ondemand_video_rounded,
            color: gamePanelGold,
          ),
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _collectRewardedRent(context);
          },
        ),
        secondaryAction: GameSecondaryButton(
          label: strings.closeLabel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }

  Future<void> _showGhostRoster(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => GameBottomSheetFrame(
        title: strings.navigationGhosts,
        icon: Icons.person_pin_circle_rounded,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final ghost in controller.state.ghosts)
                ListTile(
                  key: Key('ghost-roster-${ghost.id}'),
                  leading: const Icon(Icons.person_pin_circle_rounded),
                  title: Text(ghost.kind.displayName),
                  subtitle: Text(
                    strings.ghostHappinessSummary(
                      ghost.kind.displayName,
                      controller.happinessFor(ghost.id),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _showGhostProfile(context, ghost.id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPropertyActions(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => GameBottomSheetFrame(
        title: strings.propertyActionsTitle,
        icon: Icons.home_work_rounded,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final room in controller.state.rooms)
                ListTile(
                  key: Key('property-room-${room.id}'),
                  leading: Icon(
                    room.unlocked ? Icons.bedroom_parent : Icons.lock_rounded,
                  ),
                  title: Text(strings.roomTitle(_roomNumber(room.id))),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _showRoomDetails(context, room.id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _collectRewardedRent(BuildContext context) async {
    final result = await controller.collectAllRentWithRewardedAd();
    if (!context.mounted) return;
    final strings = AppLocalizations.of(context);
    final message = switch (result) {
      RewardedRentBonusEarned(:final bonusCoins) => strings.rewardedRentEarned(
        bonusCoins,
      ),
      RewardedRentBaseOnly(:final baseCoins) => strings.rewardedRentBaseOnly(
        baseCoins,
      ),
      RewardedRentNoClaim() => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showOfflineReturn(BuildContext context, int coins) async {
    final strings = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameDialog(
        key: const Key('offline-return-panel'),
        title: strings.offlineReturnTitle,
        icon: Icons.nights_stay_rounded,
        // ignore: sort_child_properties_last
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.savings_rounded, size: 54, color: gamePanelGold),
            const SizedBox(height: 12),
            Text(
              strings.offlineReturnBody(coins),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        primaryAction: GamePrimaryButton(
          key: const Key('offline-return-continue'),
          label: strings.collectLabel,
          icon: Icons.check_rounded,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
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
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) => GameBottomSheetFrame(
          title: strings.roomTitle(_roomNumber(roomId)),
          icon: Icons.lock_rounded,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(key: Key('selected-$roomId')),
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
                    child: GamePrimaryButton(
                      key: Key('unlock-${room.id}'),
                      onPressed:
                          controller.state.playerLevel >=
                                  ProgressionDefinitions.requiredLevelForRoom(
                                    room.id,
                                  ) &&
                              controller.state.walletCoins >=
                                  GameBalance.roomUnlockCosts[room.id]!
                          ? () async {
                              Navigator.pop(sheetContext);
                              await controller.unlockRoom(room.id);
                            }
                          : null,
                      label: strings.unlockRoom,
                      icon: Icons.lock_open_rounded,
                    ),
                  ),
                ],
              ],
            ),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
      builder: (dialogContext) => GameDialog(
        title: strings.languageTitle,
        icon: Icons.language_rounded,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameChoiceCard(
              key: const Key('language-id'),
              onPressed: () => Navigator.pop(dialogContext, 'id'),
              title: strings.languageIndonesian,
              subtitle: '',
            ),
            GameChoiceCard(
              key: const Key('language-en'),
              onPressed: () => Navigator.pop(dialogContext, 'en'),
              title: strings.languageEnglish,
              subtitle: '',
            ),
          ],
        ),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
      builder: (dialogContext) => GameDialog(
        title: strings.chooseDestination,
        icon: Icons.swap_horiz_rounded,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final room in destinations)
              GameChoiceCard(
                key: Key('destination-${room.id}'),
                onPressed: () => Navigator.pop(dialogContext, room.id),
                title: room.occupantId == null
                    ? strings.vacantRoom(_roomNumber(room.id))
                    : strings.occupiedRoom(_roomNumber(room.id)),
                subtitle: '',
              ),
          ],
        ),
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
      builder: (dialogContext) => GameDialog(
        title: strings.confirmSwapTitle,
        icon: Icons.swap_horiz_rounded,
        // ignore: sort_child_properties_last
        child: Text(strings.confirmSwapBody(_roomNumber(targetRoomId))),
        secondaryAction: GameSecondaryButton(
          label: strings.cancel,
          onPressed: () => Navigator.pop(dialogContext, false),
        ),
        primaryAction: GamePrimaryButton(
          key: const Key('confirm-swap'),
          onPressed: () => Navigator.pop(dialogContext, true),
          label: strings.confirmSwap,
          icon: Icons.swap_horiz_rounded,
        ),
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
      builder: (dialogContext) => GameDialog(
        title: _localized(context, incident.title!),
        icon: Icons.crisis_alert_rounded,
        // ignore: sort_child_properties_last
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_localized(context, incident.dialogue!)),
              const SizedBox(height: 16),
              for (final choice in incident.choices) ...[
                GameChoiceCard(
                  key: Key('incident-choice-${choice.id}'),
                  enabled:
                      controller.state.walletCoins + choice.effects.coinDelta >=
                      0,
                  onPressed: () => Navigator.pop(dialogContext, choice),
                  title: _localized(context, choice.label),
                  subtitle:
                      '${strings.incidentConsequencePreview(_effectPreview(context, choice.effects))}'
                      '${controller.state.walletCoins + choice.effects.coinDelta < 0 ? '\n${strings.incidentNotEnoughCoins}' : ''}',
                ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
        secondaryAction: GameSecondaryButton(
          label: strings.cancel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    final committed = await controller.resolveIncident(incident.id, choice.id);
    if (!committed || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameDialog(
        title: strings.incidentResolvedTitle,
        icon: Icons.auto_awesome_rounded,
        // ignore: sort_child_properties_last
        child: Text(
          '${_localized(context, choice.response)}\n\n'
          '${strings.incidentConsequencePreview(_effectPreview(context, choice.effects))}',
        ),
        primaryAction: GamePrimaryButton(
          key: const Key('incident-outcome-continue'),
          onPressed: () => Navigator.pop(dialogContext),
          label: strings.continueLabel,
        ),
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
      builder: (dialogContext) => GameDialog(
        title: strings.complaintTitle,
        icon: Icons.campaign_rounded,
        // ignore: sort_child_properties_last
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.complaintBody),
              const SizedBox(height: 12),
              _ChoiceButton(
                key: const Key('choice-soundproof'),
                title: strings.installSoundproofing,
                effect: strings.soundproofingEffect,
                onPressed: () => Navigator.pop(
                  dialogContext,
                  ComplaintChoice.installSoundproofing,
                ),
              ),
              _ChoiceButton(
                title: strings.askTuyulCalm,
                effect: strings.askTuyulCalmEffect,
                onPressed: () => Navigator.pop(
                  dialogContext,
                  ComplaintChoice.askTuyulToCalmDown,
                ),
              ),
              _ChoiceButton(
                title: strings.peaceOffering,
                effect: strings.peaceOfferingEffect,
                onPressed: () =>
                    Navigator.pop(dialogContext, ComplaintChoice.peaceOffering),
              ),
            ],
          ),
        ),
        secondaryAction: GameSecondaryButton(
          label: strings.cancel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
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
  Widget build(BuildContext context) =>
      GameChoiceCard(title: title, subtitle: effect, onPressed: onPressed);
}
