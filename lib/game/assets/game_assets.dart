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

  static const backgroundMusic = 'audio/music/horror_comedy_night_suite.wav';
  static const tensionMusic = 'audio/music/malam_jumat_mischief.wav';
  static const Map<String, String> audioEffects = {
    'coin': 'audio/sfx/rent_collect_jingle.wav',
    'upgrade': 'audio/sfx/upgrade_hammer_pop.wav',
    'unlock': 'audio/sfx/room_unlock_magic.wav',
    'incident': 'audio/sfx/incident_alert_comedy.wav',
    'incidentGood': 'audio/sfx/incident_choice_good.wav',
    'incidentBad': 'audio/sfx/incident_choice_bad.wav',
    'repair': 'audio/sfx/repair_tap_tap.wav',
    'ambienceCricket': 'audio/sfx/ambient_cricket_chirp.wav',
    'ambienceBreeze': 'audio/sfx/ambient_spooky_breeze.wav',
    'reward': 'audio/sfx/reward_big_fanfare.wav',
    'furniture': 'audio/sfx/furniture_drop_bounce.wav',
    'pocong': 'audio/sfx/ghost_pocong_hop.wav',
    'pocongHappy': 'audio/sfx/ghost_pocong_happy.wav',
    'kuntilanak': 'audio/sfx/ghost_kuntilanak_complaint.wav',
    'kuntilanakHappy': 'audio/sfx/ghost_kuntilanak_giggle.wav',
    'tuyul': 'audio/sfx/ghost_tuyul_sneak.wav',
    'tuyulHappy': 'audio/sfx/ghost_tuyul_prank.wav',
    'genderuwo': 'audio/sfx/ghost_genderuwo_step.wav',
    'genderuwoHappy': 'audio/sfx/ghost_genderuwo_chuckle.wav',
    'ghostAngry': 'audio/sfx/ghost_general_angry.wav',
    'uiClick': 'audio/sfx/ui_tap_bubble.wav',
    'uiConfirm': 'audio/sfx/ui_confirm_pop.wav',
    'uiCancel': 'audio/sfx/ui_cancel_wobble.wav',
    'unavailable': 'audio/sfx/purchase_insufficient.wav',
  };
}
