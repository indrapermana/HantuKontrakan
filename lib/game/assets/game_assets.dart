import '../../simulation/models/ghost.dart';

abstract final class GameAssets {
  static const cutaway = 'environment/kontrakan_cutaway.png';
  static const spiritCoin = 'assets/images/ui/koin_arwah.png';
  static const settingsIcon = 'assets/images/ui/settings.png';

  static const Map<GhostKind, String> ghostAtlases = {
    GhostKind.pocong: 'ghosts/pocong_atlas.png',
    GhostKind.kuntilanak: 'ghosts/kuntilanak_atlas.png',
    GhostKind.tuyul: 'ghosts/tuyul_atlas.png',
    GhostKind.genderuwo: 'ghosts/genderuwo_atlas.png',
  };

  static const backgroundMusic = 'audio/music/cozy_night_loop.wav';
  static const Map<String, String> audioEffects = {
    'coin': 'audio/sfx/coin_collect.wav',
    'upgrade': 'audio/sfx/room_upgrade.wav',
    'unlock': 'audio/sfx/room_unlock.wav',
    'incident': 'audio/sfx/event_alert.wav',
    'repair': 'audio/sfx/repair.wav',
    'ghost': 'audio/sfx/ghost_appear.wav',
  };
}
