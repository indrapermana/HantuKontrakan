import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/application/game_controller.dart';
import 'package:hantu_kontrakan/services/save_service.dart';
import 'package:hantu_kontrakan/simulation/systems/game_rules.dart';

void main() {
  test(
    'resolved complaint and swapped rooms survive controller reload',
    () async {
      final saves = MemorySaveService();
      final first = GameController(saveService: saves);
      await first.initialize();
      await first.swapFrom('room_01');
      await first.resolveComplaint(ComplaintChoice.peaceOffering);

      final reloaded = GameController(saveService: saves);
      await reloaded.initialize();

      expect(reloaded.state.walletCoins, 175);
      expect(reloaded.state.complaintResolved, isTrue);
      expect(reloaded.state.roomById('room_01').occupantId, 'tuyul_01');
      expect(reloaded.happinessFor('pocong_01'), 40);
    },
  );
}
