import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../features/debug/debug_hud.dart';
import '../../game/hantu_game.dart';
import '../../l10n/app_localizations.dart';
import '../../simulation/constants/game_balance.dart';
import '../../simulation/content/incident_definitions.dart';
import '../../simulation/content/mission_definitions.dart';
import '../../simulation/content/progression_definitions.dart';
import '../../simulation/content/property_definitions.dart';
import '../../simulation/models/incident_definition.dart';
import '../../simulation/models/mission_definition.dart';
import '../../simulation/systems/daily_goal_system.dart';
import '../../simulation/systems/game_rules.dart';
import '../../simulation/systems/mission_system.dart';
import '../../simulation/systems/portfolio_system.dart';
import '../../simulation/systems/rent_system.dart';
import '../../widgets/game_panel.dart';
import '../missions/mission_dialog.dart';
import '../settings/audio_settings_dialog.dart';
import '../tutorial/tutorial_panel.dart';
import 'detail_sheets.dart';
import 'game_feedback_overlay.dart';
import 'home_game_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.controller,
    this.showDebugTools = false,
    super.key,
  });

  final GameController controller;
  final bool showDebugTools;

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
        final offlineEarnings = controller.takePendingOfflineEarnings();
        if (offlineEarnings.totalCoins > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _showOfflineReturn(context, offlineEarnings);
            }
          });
        }
        final activeIncident = state.activeIncidentId == null
            ? null
            : IncidentDefinitions.byId(state.activeIncidentId!);
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
        final hasMissionReward =
            MissionDefinitions.all.any(
              (mission) => MissionSystem.isClaimable(state, mission),
            ) ||
            controller.dailyGoals.any(
              (goal) => DailyGoalSystem.isClaimable(state, goal),
            ) ||
            DailyGoalSystem.isChestClaimable(state);
        final media = MediaQuery.of(context);
        const hudHeight = 62.0;
        const navigationHeight = 76.0;
        final worldTop = media.padding.top + hudHeight;
        final worldBottom = media.padding.bottom + navigationHeight;
        return Scaffold(
          backgroundColor: const Color(0xFF111631),
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: ColoredBox(
                  key: Key('portrait-world-backdrop'),
                  color: Color(0xFF111631),
                ),
              ),
              Positioned(
                key: const Key('portrait-world-stage'),
                top: worldTop,
                right: 0,
                bottom: worldBottom,
                left: 0,
                child: SizedBox.expand(
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
              ),
              GameFeedbackOverlay(
                signal: controller.feedbackSignal,
                reducedMotion:
                    state.reducedMotionEnabled ||
                    MediaQuery.disableAnimationsOf(context),
              ),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: HomeGameHud(
                    levelLabel: 'Lv. ${state.playerLevel}',
                    experienceProgress: levelProgress,
                    coinLabel: '${state.walletCoins}',
                    coinSemanticsLabel: strings.spiritCoins(state.walletCoins),
                    crystalLabel: '${state.mysticalCrystals}',
                    crystalSemanticsLabel: strings.mysticalCrystals(
                      state.mysticalCrystals,
                    ),
                    settingsTooltip: strings.settingsTitle,
                    languageTooltip: strings.languageTitle,
                    onLevel: () => _showLevelProgress(context),
                    onCoins: () => _showCoinInfo(context),
                    onCrystals: () => _showCrystalInfo(context),
                    onSettings: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          AudioSettingsDialog(controller: controller),
                    ),
                    onLanguage: () => _showLanguagePicker(context),
                  ),
                ),
              ),
              if (showDebugTools)
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
                  padding: EdgeInsets.only(top: showDebugTools ? 142 : 74),
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
              Positioned(
                top: worldTop,
                right: 0,
                bottom: worldBottom,
                left: 0,
                child: RoomRentBubbleOverlay(
                  coinsByRoom: controller.pendingRentCoinsByRoom,
                  labelFor: (roomId, coins) =>
                      strings.roomRentBubbleLabel(coins, _roomNumber(roomId)),
                  onCollect: (roomId) => _collectRoomRent(context, roomId),
                ),
              ),
              WorldActionOverlay(
                collectLabel: strings.collectAllRent(
                  controller.pendingRentCoins,
                ),
                canCollect: controller.pendingRentCoins > 0,
                onCollect: () => _collectAllRent(context),
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
              ),
              HomeBottomNavigation(
                homeLabel: strings.navigationHome,
                missionsLabel: strings.missionsTitle,
                ghostsLabel: strings.navigationGhosts,
                shopLabel: strings.navigationShop,
                showMissionsBadge: hasMissionReward,
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

  Future<void> _showLevelProgress(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final state = controller.state;
    final nextLevel = state.playerLevel < ProgressionDefinitions.levels.length
        ? ProgressionDefinitions.byLevel(state.playerLevel + 1)
        : null;
    final remainingMissions = MissionDefinitions.all
        .where((mission) => !state.completedMissionIds.contains(mission.id))
        .take(3)
        .toList(growable: false);
    final unlocks = <String>[
      if (nextLevel != null)
        for (final roomId in nextLevel.unlockedRoomIds)
          strings.roomTitle(_roomNumber(roomId)),
      if (nextLevel != null)
        for (final kind in nextLevel.unlockedGhostKinds) kind.displayName,
    ];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        key: const Key('level-progress-panel'),
        title: strings.levelProgressTitle(state.playerLevel),
        icon: Icons.star_rounded,
        // ignore: sort_child_properties_last
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              nextLevel == null
                  ? strings.maximumLevelReached
                  : strings.levelExperienceProgress(
                      state.playerExperience,
                      nextLevel.requiredExperience,
                    ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: nextLevel == null
                  ? 1
                  : (state.playerExperience / nextLevel.requiredExperience)
                        .clamp(0, 1),
              minHeight: 9,
              borderRadius: BorderRadius.circular(5),
              color: gamePanelGold,
            ),
            if (nextLevel != null) ...[
              const SizedBox(height: 12),
              Text(
                unlocks.isEmpty
                    ? strings.nextLevelMoreRewards(nextLevel.level)
                    : strings.nextLevelUnlocks(
                        nextLevel.level,
                        unlocks.join(' · '),
                      ),
              ),
            ],
            if (remainingMissions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                strings.levelChecklistTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final mission in remainingMissions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    MissionSystem.isComplete(state, mission)
                        ? Icons.card_giftcard_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: gamePanelGold,
                  ),
                  title: Text(_localizedMission(context, mission.title)),
                  subtitle: Text(
                    _localizedMission(context, mission.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ],
        ),
        primaryAction: GamePrimaryButton(
          label: strings.viewTasks,
          icon: Icons.assignment_turned_in_rounded,
          onPressed: () async {
            Navigator.pop(dialogContext);
            await showDialog<void>(
              context: context,
              builder: (_) => MissionDialog(controller: controller),
            );
          },
        ),
        secondaryAction: GameSecondaryButton(
          label: strings.closeLabel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }

  Future<void> _showCoinInfo(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final microcoins = RentSystem.totalRentPerMinuteMicrocoins(
      controller.state,
    );
    final rate = microcoins / GameBalance.microcoinsPerCoin;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        key: const Key('coin-info-panel'),
        title: strings.coinInfoTitle,
        icon: Icons.savings_rounded,
        // ignore: sort_child_properties_last
        child: Text(
          strings.coinInfoBody(
            controller.state.walletCoins,
            rate.toStringAsFixed(1),
          ),
          textAlign: TextAlign.center,
        ),
        primaryAction: GamePrimaryButton(
          label: strings.closeLabel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }

  Future<void> _showCrystalInfo(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        key: const Key('crystal-info-panel'),
        title: strings.crystalInfoTitle,
        icon: Icons.diamond_rounded,
        // ignore: sort_child_properties_last
        child: Text(
          strings.crystalInfoBody(controller.state.mysticalCrystals),
          textAlign: TextAlign.center,
        ),
        primaryAction: GamePrimaryButton(
          label: strings.openWorkshop,
          icon: Icons.storefront_rounded,
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _showPropertyActions(context);
          },
        ),
        secondaryAction: GameSecondaryButton(
          label: strings.viewTasks,
          onPressed: () async {
            Navigator.pop(dialogContext);
            await showDialog<void>(
              context: context,
              builder: (_) => MissionDialog(controller: controller),
            );
          },
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
                    '${strings.ghostHappinessSummary(ghost.kind.displayName, controller.happinessFor(ghost.id))}\n'
                    '${_ghostStoryStatus(strings, ghost.id)}',
                  ),
                  isThreeLine: true,
                  trailing:
                      controller.state.completedGhostStoryIds.contains(ghost.id)
                      ? const Icon(Icons.auto_stories_rounded)
                      : IconButton(
                          key: Key('ghost-story-${ghost.id}'),
                          tooltip: strings.rememberStory,
                          onPressed:
                              controller.state.roomForGhost(ghost.id) == null
                              ? null
                              : () async {
                                  await controller.completeGhostStory(ghost.id);
                                },
                          icon: const Icon(Icons.menu_book_rounded),
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
        title: strings.propertyPortfolioTitle,
        icon: Icons.home_work_rounded,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _propertyName(strings, controller.state.activePropertyId),
                key: const Key('active-property-name'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                strings.ghostCollectionProgress(
                  controller.state.completedGhostStoryIds.length,
                  controller.state.ghosts.length,
                ),
              ),
              const SizedBox(height: 12),
              for (final propertyId in controller.state.propertyRoomsById.keys)
                ListTile(
                  key: Key('portfolio-property-$propertyId'),
                  leading: const Icon(Icons.apartment_rounded),
                  title: Text(_propertyName(strings, propertyId)),
                  subtitle: Text(
                    '${controller.state.propertyRoomsById[propertyId]!.where((room) => room.occupantId != null).length}/'
                    '${controller.state.propertyRoomsById[propertyId]!.length}',
                  ),
                  trailing: propertyId == controller.state.activePropertyId
                      ? Text(strings.propertyActive)
                      : TextButton(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await controller.switchProperty(propertyId);
                          },
                          child: Text(strings.propertyVisit),
                        ),
                ),
              if (!controller.state.propertyRoomsById.containsKey(
                PropertyDefinitions.secondPropertyId,
              ))
                GameChoiceCard(
                  key: const Key('unlock-second-property'),
                  title: strings.propertySecondName,
                  subtitle:
                      PortfolioSystem.canUnlockSecondProperty(controller.state)
                      ? strings.propertyReady
                      : strings.propertyLocked,
                  leading: const Icon(Icons.add_business_rounded),
                  enabled: PortfolioSystem.canUnlockSecondProperty(
                    controller.state,
                  ),
                  onPressed: () async {
                    await controller.unlockSecondProperty();
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              const SizedBox(height: 12),
              Text(
                strings.ownedFurnitureTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('${controller.state.ownedFurnitureIds.length}'),
              const SizedBox(height: 12),
              Text(
                strings.crystalFurnitureTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final entry
                  in PortfolioSystem.premiumFurnitureCrystalCosts.entries)
                ListTile(
                  key: Key('premium-furniture-${entry.key}'),
                  leading: const Icon(Icons.diamond_rounded),
                  title: Text(localizedFurniture(strings, entry.key)),
                  subtitle: Text(strings.buyForCrystals(entry.value)),
                  trailing:
                      controller.state.ownedFurnitureIds.contains(entry.key)
                      ? const Icon(Icons.check_circle_rounded)
                      : FilledButton(
                          onPressed:
                              controller.state.mysticalCrystals >= entry.value
                              ? () => controller.purchaseFurniture(entry.key)
                              : null,
                          child: Text('${entry.value}'),
                        ),
                ),
              const Divider(),
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

  String _ghostStoryStatus(AppLocalizations strings, String ghostId) {
    if (controller.state.completedGhostStoryIds.contains(ghostId)) {
      return strings.ghostStoryComplete;
    }
    return controller.state.roomForGhost(ghostId) == null
        ? strings.ghostStoryLocked
        : strings.ghostStoryReady;
  }

  Future<void> _collectRewardedRent(BuildContext context) async {
    final result = await controller.collectAllRentWithRewardedAd(
      bonusCoins: controller.pendingRewardOfferCoins,
    );
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

  Future<void> _collectAllRent(BuildContext context) async {
    final collected = await controller.collectAllRent();
    if (!context.mounted || collected <= 0) return;
    await _showRentCollected(
      context,
      title: AppLocalizations.of(context).rentCollectedTitle,
      message: AppLocalizations.of(context).allRentCollected(collected),
      collectedCoins: collected,
    );
  }

  Future<void> _collectRoomRent(BuildContext context, String roomId) async {
    final collected = await controller.collectRoomRent(roomId);
    if (!context.mounted || collected <= 0) return;
    final strings = AppLocalizations.of(context);
    await _showRentCollected(
      context,
      title: strings.rentCollectedTitle,
      message: strings.roomRentCollected(collected, _roomNumber(roomId)),
      collectedCoins: collected,
    );
  }

  Future<void> _showRentCollected(
    BuildContext context, {
    required String title,
    required String message,
    required int collectedCoins,
  }) async {
    final strings = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        key: const Key('rent-collected-panel'),
        title: title,
        icon: Icons.savings_rounded,
        // ignore: sort_child_properties_last
        child: Text(message, textAlign: TextAlign.center),
        secondaryAction: GameSecondaryButton(
          label: strings.closeLabel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
        primaryAction: controller.canCollectRewardedRent
            ? GamePrimaryButton(
                key: const Key('post-collect-rewarded-offer'),
                label: strings.rewardedRentButton(
                  collectedCoins,
                  controller.rewardedRentBonusesRemaining,
                ),
                icon: Icons.ondemand_video_rounded,
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _collectRewardedRent(context);
                },
              )
            : null,
      ),
    );
  }

  Future<void> _showOfflineReturn(
    BuildContext context,
    OfflineEarningsPresentation earnings,
  ) async {
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
              strings.offlineReturnBody(earnings.totalCoins),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final entry in earnings.coinsByRoom.entries) ...[
              const SizedBox(height: 6),
              Text(
                strings.offlineRoomContribution(
                  entry.value,
                  _roomNumber(entry.key),
                ),
                key: Key('offline-room-${entry.key}'),
              ),
            ],
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
        onAssignGhost: ghost == null
            ? () async {
                Navigator.pop(sheetContext);
                await _chooseTenantForRoom(context, room.id);
              }
            : null,
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
        onAssignGhost: room == null
            ? () async {
                Navigator.pop(sheetContext);
                await _chooseRoomForTenant(context, ghost.id);
              }
            : null,
        onMoveGhost: room == null
            ? () {}
            : () async {
                Navigator.pop(sheetContext);
                await _chooseDestination(context, ghost.id, room.id);
              },
      ),
    );
  }

  Future<void> _chooseTenantForRoom(BuildContext context, String roomId) async {
    final strings = AppLocalizations.of(context);
    final candidates = controller.state.ghosts
        .where((ghost) {
          if (controller.state.roomForGhost(ghost.id) != null) return false;
          return !identical(
            GameRules.placeGhost(controller.state, ghost.id, roomId),
            controller.state,
          );
        })
        .toList(growable: false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        key: const Key('choose-tenant-panel'),
        title: strings.chooseTenantForRoom(_roomNumber(roomId)),
        icon: Icons.person_add_alt_1_rounded,
        // ignore: sort_child_properties_last
        child: candidates.isEmpty
            ? Text(strings.noAvailableTenants)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final ghost in candidates)
                    GameChoiceCard(
                      key: Key('assign-${ghost.id}-$roomId'),
                      title: ghost.kind.displayName,
                      subtitle: localizedArchetype(strings, ghost.kind),
                      leading: const Icon(
                        Icons.person_pin_circle_rounded,
                        color: gamePanelGold,
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await controller.placeGhost(ghost.id, roomId);
                      },
                    ),
                ],
              ),
        secondaryAction: GameSecondaryButton(
          label: strings.cancel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }

  Future<void> _chooseRoomForTenant(
    BuildContext context,
    String ghostId,
  ) async {
    final strings = AppLocalizations.of(context);
    final rooms = controller.state.rooms
        .where((room) {
          if (!room.unlocked || room.occupantId != null) return false;
          return !identical(
            GameRules.placeGhost(controller.state, ghostId, room.id),
            controller.state,
          );
        })
        .toList(growable: false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GameDialog(
        key: const Key('choose-room-panel'),
        title: strings.chooseRoomForTenant,
        icon: Icons.add_home_rounded,
        // ignore: sort_child_properties_last
        child: rooms.isEmpty
            ? Text(strings.noAvailableRooms)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final room in rooms)
                    GameChoiceCard(
                      key: Key('assign-$ghostId-${room.id}'),
                      title: strings.roomTitle(_roomNumber(room.id)),
                      subtitle: strings.vacantTenant,
                      leading: const Icon(
                        Icons.bedroom_parent_rounded,
                        color: gamePanelGold,
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await controller.placeGhost(ghostId, room.id);
                      },
                    ),
                ],
              ),
        secondaryAction: GameSecondaryButton(
          label: strings.cancel,
          onPressed: () => Navigator.pop(dialogContext),
        ),
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

String _propertyName(AppLocalizations strings, String propertyId) =>
    switch (propertyId) {
      PropertyDefinitions.firstPropertyId => strings.propertyFirstName,
      PropertyDefinitions.secondPropertyId => strings.propertySecondName,
      _ => propertyId,
    };

String _localizedMission(BuildContext context, LocalizedMissionText text) =>
    Localizations.localeOf(context).languageCode == 'id' ? text.id : text.en;

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
