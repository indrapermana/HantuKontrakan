import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../features/debug/debug_hud.dart';
import '../../game/hantu_game.dart';
import '../../l10n/app_localizations.dart';
import '../../simulation/systems/game_rules.dart';
import '../../simulation/systems/happiness_system.dart';

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
        final pocongHappiness = controller.happinessFor('pocong_01');
        return Scaffold(
          appBar: AppBar(
            title: Text(strings.appTitleUppercase),
            centerTitle: true,
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
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GameWidget(
                      key: ValueKey(controller.revision),
                      game: HantuGame(
                        state: state,
                        onRoomTap: (roomId) =>
                            _showRoomDetails(context, roomId),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
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
    if (room == null) {
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
              Text(strings.roomUnlockLater),
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
      builder: (context) => Padding(
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
            if (ghost != null) ...[
              Text('${ghost.kind.displayName} — ${ghost.kind.archetype}'),
              const SizedBox(height: 8),
              Text(
                strings.happinessDetail(
                  controller.happinessFor(ghost.id),
                  _localizedMood(strings, controller.happinessFor(ghost.id)),
                ),
              ),
              Text(
                strings.neighborCompatibility(
                  controller.compatibilityFor(ghost.id),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('swap-tenants'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await controller.swapFrom(room.id);
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(strings.swapTenant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _roomNumber(String roomId) => roomId.split('_').last;

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

  String _localizedMood(AppLocalizations strings, int happiness) {
    final mood = HappinessSystem.moodFor(happiness);
    return switch (mood) {
      'Senang' => strings.moodHappy,
      'Nyaman' => strings.moodComfortable,
      'Tidak senang' => strings.moodUnhappy,
      _ => strings.moodAngry,
    };
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
