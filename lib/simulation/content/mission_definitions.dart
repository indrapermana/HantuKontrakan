import '../models/mission_definition.dart';

abstract final class MissionDefinitions {
  static const List<MissionDefinition> all = [
    MissionDefinition(
      id: 'place_pocong',
      title: LocalizedMissionText(id: 'Penghuni Pertama', en: 'First Tenant'),
      description: LocalizedMissionText(
        id: 'Tempatkan Pocong di sebuah kamar.',
        en: 'Place Pocong in a room.',
      ),
      objective: MissionObjective.placeGhost,
      targetId: 'pocong_01',
      reward: MissionReward(coins: 25, experience: 25),
    ),
    MissionDefinition(
      id: 'collect_first_rent',
      title: LocalizedMissionText(id: 'Sewa Pertama', en: 'First Rent'),
      description: LocalizedMissionText(
        id: 'Ambil sewa pertamamu.',
        en: 'Collect your first rent.',
      ),
      objective: MissionObjective.collectRent,
      prerequisiteMissionId: 'place_pocong',
      reward: MissionReward(coins: 30, experience: 25),
    ),
    MissionDefinition(
      id: 'place_kuntilanak',
      title: LocalizedMissionText(
        id: 'Tetangga Dramatis',
        en: 'Dramatic Neighbor',
      ),
      description: LocalizedMissionText(
        id: 'Tempatkan Kuntilanak di sebuah kamar.',
        en: 'Place Kuntilanak in a room.',
      ),
      objective: MissionObjective.placeGhost,
      targetId: 'kuntilanak_01',
      prerequisiteMissionId: 'collect_first_rent',
      reward: MissionReward(coins: 40, experience: 50),
    ),
    MissionDefinition(
      id: 'resolve_first_incident',
      title: LocalizedMissionText(id: 'Ambil Keputusan', en: 'Make a Call'),
      description: LocalizedMissionText(
        id: 'Selesaikan sebuah insiden.',
        en: 'Resolve an incident.',
      ),
      objective: MissionObjective.resolveIncident,
      prerequisiteMissionId: 'place_kuntilanak',
      reward: MissionReward(coins: 50, experience: 50),
    ),
    MissionDefinition(
      id: 'upgrade_comfort',
      title: LocalizedMissionText(id: 'Lebih Nyaman', en: 'More Comfortable'),
      description: LocalizedMissionText(
        id: 'Tingkatkan Kenyamanan sebuah kamar.',
        en: 'Upgrade a room’s Comfort.',
      ),
      objective: MissionObjective.upgradeComfort,
      prerequisiteMissionId: 'resolve_first_incident',
      reward: MissionReward(coins: 75, experience: 75),
    ),
    MissionDefinition(
      id: 'furnish_room',
      title: LocalizedMissionText(id: 'Sentuhan Rumah', en: 'A Homely Touch'),
      description: LocalizedMissionText(
        id: 'Pasang sebuah furnitur.',
        en: 'Equip a piece of furniture.',
      ),
      objective: MissionObjective.equipFurniture,
      prerequisiteMissionId: 'upgrade_comfort',
      reward: MissionReward(coins: 50, experience: 75),
    ),
    MissionDefinition(
      id: 'happy_tenant',
      title: LocalizedMissionText(id: 'Penghuni Senang', en: 'Happy Tenant'),
      description: LocalizedMissionText(
        id: 'Capai kebahagiaan penghuni 70 atau lebih.',
        en: 'Raise a tenant’s happiness to 70 or higher.',
      ),
      objective: MissionObjective.reachHappiness,
      targetValue: 70,
      prerequisiteMissionId: 'furnish_room',
      reward: MissionReward(experience: 100, mysticalCrystals: 2),
    ),
    MissionDefinition(
      id: 'place_tuyul',
      title: LocalizedMissionText(id: 'Kolektor Cilik', en: 'Little Collector'),
      description: LocalizedMissionText(
        id: 'Tempatkan Tuyul di sebuah kamar.',
        en: 'Place Tuyul in a room.',
      ),
      objective: MissionObjective.placeGhost,
      targetId: 'tuyul_01',
      prerequisiteMissionId: 'happy_tenant',
      reward: MissionReward(coins: 100, experience: 150),
    ),
    MissionDefinition(
      id: 'unlock_room_03',
      title: LocalizedMissionText(
        id: 'Perluas Kontrakan',
        en: 'Expand Upstairs',
      ),
      description: LocalizedMissionText(
        id: 'Buka Kamar 3.',
        en: 'Unlock Room 3.',
      ),
      objective: MissionObjective.unlockRoom,
      targetId: 'room_03',
      prerequisiteMissionId: 'place_tuyul',
      reward: MissionReward(coins: 150, experience: 250),
    ),
    MissionDefinition(
      id: 'reach_level_5',
      title: LocalizedMissionText(
        id: 'Juragan Kontrakan',
        en: 'Kontrakan Boss',
      ),
      description: LocalizedMissionText(
        id: 'Capai level pemain 5.',
        en: 'Reach player level 5.',
      ),
      objective: MissionObjective.reachLevel,
      targetValue: 5,
      prerequisiteMissionId: 'unlock_room_03',
      reward: MissionReward(coins: 200, experience: 250, mysticalCrystals: 3),
    ),
  ];

  static MissionDefinition? byId(String id) =>
      all.where((mission) => mission.id == id).firstOrNull;
}
