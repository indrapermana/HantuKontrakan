import 'package:flutter/material.dart';

import '../../application/game_controller.dart';

class DebugHud extends StatelessWidget {
  const DebugHud({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Card(
      key: const Key('debug-hud'),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      color: const Color(0xDD241F3D),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DEBUG  Coins ${state.walletCoins}  Chaos ${state.chaos}  '
                    'Tick ${state.activeSimulationSeconds}  '
                    'Rent ${controller.pendingRentCoins}  '
                    'Rep ${state.reputation}',
                    key: const Key('debug-stats'),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    'P ${controller.happinessFor('pocong_01')}  '
                    'T ${controller.happinessFor('tuyul_01')}  '
                    'Seed ${controller.randomSeed}  '
                    '${controller.debugNow.toIso8601String()}',
                    key: const Key('debug-runtime'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('debug-tick'),
              tooltip: 'Advance one deterministic tick',
              visualDensity: VisualDensity.compact,
              onPressed: controller.debugTick,
              icon: const Icon(Icons.skip_next),
            ),
            IconButton(
              key: const Key('debug-special'),
              tooltip: 'Toggle Pocong special animation',
              visualDensity: VisualDensity.compact,
              onPressed: () => controller.setGhostSpecialAction(
                'pocong_01',
                !state.ghostById('pocong_01').specialActionActive,
              ),
              icon: Icon(
                state.ghostById('pocong_01').specialActionActive
                    ? Icons.auto_awesome
                    : Icons.auto_awesome_outlined,
              ),
            ),
            IconButton(
              key: const Key('debug-reset'),
              tooltip: 'Reset seeded state',
              visualDensity: VisualDensity.compact,
              onPressed: controller.resetState,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
      ),
    );
  }
}
