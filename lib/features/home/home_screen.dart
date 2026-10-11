import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../application/game_controller.dart';
import '../../game/hantu_game.dart';
import '../../simulation/models/room.dart';
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
        if (!controller.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final state = controller.state;
        final pocongHappiness = controller.happinessFor('pocong_01');
        return Scaffold(
          appBar: AppBar(
            title: const Text('HANTU KONTRAKAN'),
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
                        '${state.walletCoins} Koin Arwah',
                        key: const Key('wallet-coins'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text('Pocong $pocongHappiness'),
                    ],
                  ),
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
                            ? 'Keluhan: Pocong terganggu Tuyul'
                            : 'Keluhan selesai dan tersimpan',
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
    final room = controller.state.roomById(roomId);
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
              _roomLabel(room),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (ghost != null) ...[
              Text('${ghost.kind.displayName} — ${ghost.kind.archetype}'),
              const SizedBox(height: 8),
              Text(
                'Kebahagiaan: ${controller.happinessFor(ghost.id)} '
                '(${HappinessSystem.moodFor(controller.happinessFor(ghost.id))})',
              ),
              Text(
                'Kompatibilitas tetangga: '
                '${controller.compatibilityFor(ghost.id)}',
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
                  label: const Text('Tukar penghuni kamar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _roomLabel(RoomState room) =>
      'KAMAR ${room.id == 'room_01' ? '01' : '02'}';

  Future<void> _showComplaint(BuildContext context) async {
    final choice = await showDialog<ComplaintChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('POCONG TIDAK BISA TIDUR!'),
        content: const Text(
          'Tuyul terus menghitung koin keras-keras di kamar sebelah. '
          'Pocong sudah kesal. Apa yang harus dilakukan?',
        ),
        actions: [
          _ChoiceButton(
            key: const Key('choice-soundproof'),
            title: 'Pasang peredam',
            effect: '−50 koin, Pocong +20 bahagia',
            onPressed: () =>
                Navigator.pop(context, ComplaintChoice.installSoundproofing),
          ),
          _ChoiceButton(
            title: 'Minta Tuyul tenang',
            effect: 'Pocong +10, Tuyul −10 bahagia',
            onPressed: () =>
                Navigator.pop(context, ComplaintChoice.askTuyulToCalmDown),
          ),
          _ChoiceButton(
            title: 'Kasih uang damai',
            effect: '−25 koin, keduanya +5 bahagia',
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
          'Keluhan selesai. Pocong sekarang '
          '${controller.happinessFor('pocong_01')} bahagia.',
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
