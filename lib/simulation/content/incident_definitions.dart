import '../models/ghost.dart';
import '../models/incident_definition.dart';

abstract final class IncidentDefinitions {
  static const List<IncidentDefinition> schedulerPool = [
    IncidentDefinition(
      id: 'pocong_midnight_exercise',
      title: LocalizedIncidentText(
        id: 'Senam Tengah Malam Pocong',
        en: "Pocong's Midnight Exercise",
      ),
      dialogue: LocalizedIncidentText(
        id: 'Pocong berlatih lompat saat semua penghuni ingin tidur.',
        en: 'Pocong practices jumps while every tenant wants to sleep.',
      ),
      requiredGhostKind: GhostKind.pocong,
      maximumGhostHappiness: 39,
      choices: [
        IncidentChoiceDefinition(
          id: 'reinforce_floor',
          label: LocalizedIncidentText(
            id: 'Perkuat lantai (-40 koin)',
            en: 'Reinforce the floor (-40 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -40,
            happinessDeltaByKind: {GhostKind.pocong: 15},
            chaosDelta: -2,
          ),
          response: LocalizedIncidentText(
            id: 'Lantai aman dan lompatan Pocong menjadi lebih tenang.',
            en: "The floor is safe and Pocong's jumps become quieter.",
          ),
        ),
        IncidentChoiceDefinition(
          id: 'set_exercise_hours',
          label: LocalizedIncidentText(
            id: 'Atur jam latihan',
            en: 'Set exercise hours',
          ),
          effects: IncidentEffects(
            happinessDeltaByKind: {GhostKind.pocong: 8},
            chaosDelta: -4,
            reputationDelta: 1,
          ),
          response: LocalizedIncidentText(
            id: 'Pocong menerima jadwal baru dengan anggukan terikat.',
            en: 'Pocong accepts the timetable with a tightly bound nod.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'tuyul_missing_sandals',
      title: LocalizedIncidentText(
        id: 'Sandal Tuyul Hilang',
        en: "Tuyul's Missing Sandals",
      ),
      dialogue: LocalizedIncidentText(
        id: 'Tuyul menuduh semua penghuni menyembunyikan sandal mininya.',
        en: 'Tuyul accuses every tenant of hiding his tiny sandals.',
      ),
      requiredGhostKind: GhostKind.tuyul,
      choices: [
        IncidentChoiceDefinition(
          id: 'buy_new_sandals',
          label: LocalizedIncidentText(
            id: 'Beli sandal baru (-20 koin)',
            en: 'Buy new sandals (-20 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -20,
            happinessDeltaByKind: {GhostKind.tuyul: 12},
            chaosDelta: -2,
          ),
          response: LocalizedIncidentText(
            id: 'Sandal baru pas meski ukurannya seperti gantungan kunci.',
            en: 'The new sandals fit despite looking like keychains.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'search_every_room',
          label: LocalizedIncidentText(
            id: 'Geledah setiap kamar',
            en: 'Search every room',
          ),
          effects: IncidentEffects(
            happinessDeltaByKind: {GhostKind.tuyul: 5, GhostKind.pocong: -3},
            chaosDelta: 2,
          ),
          response: LocalizedIncidentText(
            id: 'Sandalnya ditemukan; privasi penghuni ikut hilang.',
            en: 'The sandals are found; tenant privacy is not.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'pak_rt_complaint',
      title: LocalizedIncidentText(
        id: 'Keluhan Pak RT',
        en: 'Pak RT Complaint',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Pak RT membawa daftar suara aneh sepanjang tiga halaman.',
        en: 'Pak RT brings three pages of strange-noise complaints.',
      ),
      cooldownSeconds: 240,
      minimumChaos: 70,
      choices: [
        IncidentChoiceDefinition(
          id: 'pay_community_fund',
          label: LocalizedIncidentText(
            id: 'Bayar kas lingkungan (-60 koin)',
            en: 'Pay the community fund (-60 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -60,
            chaosDelta: -10,
            reputationDelta: 6,
          ),
          response: LocalizedIncidentText(
            id: 'Daftar keluhan berubah menjadi tanda terima kas.',
            en: 'The complaint list becomes a community-fund receipt.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'join_patrol',
          label: LocalizedIncidentText(
            id: 'Minta maaf dan ikut ronda',
            en: 'Apologize and join patrol',
          ),
          effects: IncidentEffects(chaosDelta: -6, reputationDelta: 4),
          response: LocalizedIncidentText(
            id: 'Pak RT puas melihat pemilik kontrakan ikut berjaga.',
            en: 'Pak RT appreciates the landlord taking a patrol shift.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'electricity_outage',
      title: LocalizedIncidentText(
        id: 'Listrik Padam',
        en: 'Electricity Outage',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Kontrakan gelap. Beberapa penghuni justru terlihat lebih jelas.',
        en: 'The building goes dark. Some tenants become easier to see.',
      ),
      choices: [
        IncidentChoiceDefinition(
          id: 'buy_emergency_lights',
          label: LocalizedIncidentText(
            id: 'Beli lampu darurat (-25 koin)',
            en: 'Buy emergency lights (-25 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -25,
            happinessDeltaByKind: {
              GhostKind.pocong: 5,
              GhostKind.kuntilanak: 5,
              GhostKind.tuyul: 5,
              GhostKind.genderuwo: 5,
            },
            chaosDelta: -3,
          ),
          response: LocalizedIncidentText(
            id: 'Lampu menyala dan bayangan kembali berperilaku normal.',
            en: 'The lights return and the shadows behave normally again.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'wait_in_the_dark',
          label: LocalizedIncidentText(
            id: 'Tunggu dalam gelap',
            en: 'Wait in the dark',
          ),
          effects: IncidentEffects(
            happinessDeltaByKind: {
              GhostKind.pocong: -5,
              GhostKind.kuntilanak: -5,
              GhostKind.tuyul: -5,
              GhostKind.genderuwo: -5,
            },
            chaosDelta: 2,
          ),
          response: LocalizedIncidentText(
            id: 'Listrik pulih. Tak ada yang membahas suara di tangga.',
            en: 'Power returns. Nobody discusses the stairwell noises.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'kuntilanak_karaoke',
      title: LocalizedIncidentText(
        id: 'Karaoke Kuntilanak',
        en: 'Kuntilanak Karaoke',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Kuntilanak yang gembira menemukan mikrofon dan nada tinggi.',
        en: 'A happy Kuntilanak discovers a microphone and high notes.',
      ),
      cooldownSeconds: 240,
      requiredGhostKind: GhostKind.kuntilanak,
      minimumGhostHappiness: 80,
      choices: [
        IncidentChoiceDefinition(
          id: 'rent_soundproofing',
          label: LocalizedIncidentText(
            id: 'Sewa peredam suara (-50 koin)',
            en: 'Rent soundproofing (-50 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -50,
            happinessDeltaByKind: {GhostKind.kuntilanak: 10},
            chaosDelta: -3,
            reputationDelta: 2,
          ),
          response: LocalizedIncidentText(
            id: 'Nada tinggi tertahan rapi di dalam kamar.',
            en: 'The high notes stay neatly inside the room.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'request_encore',
          label: LocalizedIncidentText(
            id: 'Minta lagu tambahan',
            en: 'Request an encore',
          ),
          effects: IncidentEffects(
            happinessDeltaByKind: {GhostKind.kuntilanak: 15},
            chaosDelta: 5,
            reputationDelta: -2,
          ),
          response: LocalizedIncidentText(
            id: 'Encore berlangsung sampai ayam tetangga menyerah.',
            en: "The encore lasts until the neighbor's rooster gives up.",
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'genderuwo_breaks_furniture',
      title: LocalizedIncidentText(
        id: 'Genderuwo Merusak Perabot',
        en: 'Genderuwo Breaks Furniture',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Sebuah kursi kalah adu kuat dengan Genderuwo.',
        en: 'A chair loses a strength contest with Genderuwo.',
      ),
      cooldownSeconds: 300,
      requiredGhostKind: GhostKind.genderuwo,
      maximumResidentRoomDurabilityLevel: 0,
      choices: [
        IncidentChoiceDefinition(
          id: 'hire_carpenter',
          label: LocalizedIncidentText(
            id: 'Panggil tukang (-80 koin)',
            en: 'Hire a carpenter (-80 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -80,
            happinessDeltaByKind: {GhostKind.genderuwo: 10},
            chaosDelta: -2,
            reputationDelta: 2,
          ),
          response: LocalizedIncidentText(
            id: 'Kursi baru hadir dengan garansi makhluk besar.',
            en: 'A new chair arrives with a large-creature warranty.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'make_him_help',
          label: LocalizedIncidentText(
            id: 'Minta Genderuwo membantu (-20 koin)',
            en: 'Ask Genderuwo to help (-20 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -20,
            happinessDeltaByKind: {GhostKind.genderuwo: -5},
            chaosDelta: -1,
            reputationDelta: 1,
          ),
          response: LocalizedIncidentText(
            id: 'Perabot terpasang miring, tetapi sangat kokoh.',
            en: 'The furniture sits crooked, but it is extremely sturdy.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'neighborhood_security_patrol',
      title: LocalizedIncidentText(
        id: 'Ronda Malam',
        en: 'Neighborhood Security Patrol',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Rombongan ronda berhenti tepat di depan kontrakan.',
        en: 'The night patrol stops directly outside the rental.',
      ),
      cooldownSeconds: 240,
      minimumReputation: 40,
      requiresOccupiedRoom: true,
      choices: [
        IncidentChoiceDefinition(
          id: 'serve_coffee',
          label: LocalizedIncidentText(
            id: 'Sajikan kopi (-30 koin)',
            en: 'Serve coffee (-30 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -30,
            chaosDelta: -4,
            reputationDelta: 6,
          ),
          response: LocalizedIncidentText(
            id: 'Ronda pulang dengan mata segar dan laporan kosong.',
            en: 'The patrol leaves alert and with an empty report.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'hide_the_ghosts',
          label: LocalizedIncidentText(
            id: 'Sembunyikan para hantu',
            en: 'Hide the ghosts',
          ),
          effects: IncidentEffects(
            happinessDeltaByKind: {
              GhostKind.pocong: -4,
              GhostKind.kuntilanak: -4,
              GhostKind.tuyul: -4,
              GhostKind.genderuwo: -4,
            },
            chaosDelta: -2,
            reputationDelta: 1,
          ),
          response: LocalizedIncidentText(
            id: 'Ronda tak melihat apa pun; penghuni merasa diselundupkan.',
            en: 'The patrol sees nothing; the tenants feel like contraband.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'paranormal_content_creator',
      title: LocalizedIncidentText(
        id: 'Kreator Konten Paranormal',
        en: 'Paranormal Content Creator Visits',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Seorang kreator datang dengan kamera dan judul sensasional.',
        en: 'A creator arrives with cameras and a sensational title.',
      ),
      cooldownSeconds: 300,
      minimumPlayerLevel: 2,
      requiresOccupiedRoom: true,
      choices: [
        IncidentChoiceDefinition(
          id: 'allow_filming',
          label: LocalizedIncidentText(
            id: 'Izinkan syuting (+50 koin)',
            en: 'Allow filming (+50 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: 50,
            happinessDeltaByKind: {
              GhostKind.pocong: -3,
              GhostKind.kuntilanak: -3,
              GhostKind.tuyul: -3,
              GhostKind.genderuwo: -3,
            },
            chaosDelta: 4,
            reputationDelta: -2,
          ),
          response: LocalizedIncidentText(
            id: 'Videonya viral. Penghuni meminta klausul privasi.',
            en: 'The video goes viral. Tenants request a privacy clause.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'host_guided_tour',
          label: LocalizedIncidentText(
            id: 'Adakan tur terpandu (+30 koin)',
            en: 'Host a guided tour (+30 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: 30,
            happinessDeltaByKind: {
              GhostKind.pocong: 3,
              GhostKind.kuntilanak: 3,
              GhostKind.tuyul: 3,
              GhostKind.genderuwo: 3,
            },
            chaosDelta: 2,
            reputationDelta: 5,
          ),
          response: LocalizedIncidentText(
            id: 'Tur tertib dan setiap kejutan sudah disetujui.',
            en: 'The tour is orderly and every scare is approved.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'mysterious_stolen_clothesline',
      title: LocalizedIncidentText(
        id: 'Jemuran Hilang Misterius',
        en: 'Mysterious Stolen Clothesline',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Tali jemuran lenyap, tetapi jepitannya membentuk pesan.',
        en: 'The clothesline vanishes, but its pegs form a message.',
      ),
      requiresOccupiedRoom: true,
      choices: [
        IncidentChoiceDefinition(
          id: 'replace_clothesline',
          label: LocalizedIncidentText(
            id: 'Ganti jemuran (-35 koin)',
            en: 'Replace the clothesline (-35 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -35,
            chaosDelta: -3,
            reputationDelta: 4,
          ),
          response: LocalizedIncidentText(
            id: 'Jemuran baru dipasang dengan gembok yang terlalu serius.',
            en: 'The new clothesline gets an excessively serious lock.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'follow_the_pegs',
          label: LocalizedIncidentText(
            id: 'Ikuti petunjuk jepitan',
            en: 'Follow the peg clues',
          ),
          effects: IncidentEffects(
            happinessDeltaByKind: {GhostKind.tuyul: 5},
            chaosDelta: 2,
            reputationDelta: 2,
          ),
          response: LocalizedIncidentText(
            id: 'Jejak berakhir di gudang bersama Tuyul yang bangga.',
            en: 'The trail ends in storage beside a very proud Tuyul.',
          ),
        ),
      ],
    ),
    IncidentDefinition(
      id: 'night_market_next_door',
      title: LocalizedIncidentText(
        id: 'Pasar Malam Sebelah Kontrakan',
        en: 'Night Market Next Door',
      ),
      dialogue: LocalizedIncidentText(
        id: 'Pasar malam muncul dengan musik keras dan aroma gorengan.',
        en: 'A night market appears with loud music and fried snacks.',
      ),
      cooldownSeconds: 240,
      minimumPlayerLevel: 2,
      choices: [
        IncidentChoiceDefinition(
          id: 'rent_a_stall',
          label: LocalizedIncidentText(
            id: 'Sewa lapak kecil (+40 koin)',
            en: 'Rent a small stall (+40 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: 40,
            happinessDeltaByKind: {
              GhostKind.pocong: 5,
              GhostKind.kuntilanak: 5,
              GhostKind.tuyul: 5,
              GhostKind.genderuwo: 5,
            },
            chaosDelta: 5,
            reputationDelta: 2,
          ),
          response: LocalizedIncidentText(
            id: 'Dagangan laris; separuh pembeli tidak punya bayangan.',
            en: 'Business booms; half the customers cast no shadows.',
          ),
        ),
        IncidentChoiceDefinition(
          id: 'negotiate_quiet_hours',
          label: LocalizedIncidentText(
            id: 'Negosiasikan jam tenang (-10 koin)',
            en: 'Negotiate quiet hours (-10 coins)',
          ),
          effects: IncidentEffects(
            coinDelta: -10,
            chaosDelta: -4,
            reputationDelta: 3,
          ),
          response: LocalizedIncidentText(
            id: 'Musik berhenti setelah satu lagu terakhir yang panjang.',
            en: 'The music stops after one remarkably long final song.',
          ),
        ),
      ],
    ),
  ];

  static IncidentDefinition? byId(String id) {
    for (final definition in schedulerPool) {
      if (definition.id == id) return definition;
    }
    return null;
  }

  static List<String> validationErrors() {
    final errors = <String>[];
    final incidentIds = <String>{};
    for (final incident in schedulerPool) {
      if (incident.id.trim().isEmpty || !incidentIds.add(incident.id)) {
        errors.add('Invalid or duplicate incident ID: ${incident.id}');
      }
      if (!_hasBothLanguages(incident.title) ||
          !_hasBothLanguages(incident.dialogue)) {
        errors.add('${incident.id}: missing localized title or dialogue');
      }
      if (incident.cooldownSeconds < 180) {
        errors.add('${incident.id}: cooldown must be at least 180 seconds');
      }
      if (incident.choices.length < 2 || incident.choices.length > 3) {
        errors.add('${incident.id}: must have 2 or 3 choices');
      }
      final choiceIds = <String>{};
      for (final choice in incident.choices) {
        if (choice.id.trim().isEmpty || !choiceIds.add(choice.id)) {
          errors.add(
            '${incident.id}: invalid or duplicate choice ${choice.id}',
          );
        }
        if (!_hasBothLanguages(choice.label) ||
            !_hasBothLanguages(choice.response)) {
          errors.add('${incident.id}/${choice.id}: missing localized text');
        }
      }
    }
    return errors;
  }

  static bool _hasBothLanguages(LocalizedIncidentText? text) =>
      text != null && text.id.trim().isNotEmpty && text.en.trim().isNotEmpty;
}
