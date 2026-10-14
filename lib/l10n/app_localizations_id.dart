// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Hantu Kontrakan';

  @override
  String get appTitleUppercase => 'HANTU KONTRAKAN';

  @override
  String spiritCoins(int count) {
    return '$count Koin Arwah';
  }

  @override
  String collectAllRent(int count) {
    return 'Ambil Semua · $count koin';
  }

  @override
  String rewardedRentButton(int coins, int remaining) {
    return 'Tonton iklan uji · $coins + $coins koin (sisa $remaining/3)';
  }

  @override
  String get rewardedRentDailyLimit => 'Batas bonus iklan harian tercapai';

  @override
  String rewardedRentEarned(int coins) {
    return 'Hadiah iklan diterima: bonus +$coins koin';
  }

  @override
  String rewardedRentBaseOnly(int coins) {
    return 'Iklan tidak tersedia atau dilewati. $coins koin dasar tetap diambil.';
  }

  @override
  String ghostHappinessSummary(String ghostName, int happiness) {
    return '$ghostName $happiness';
  }

  @override
  String get pendingComplaint => 'Keluhan: Pocong terganggu Tuyul';

  @override
  String get resolvedComplaint => 'Keluhan selesai dan tersimpan';

  @override
  String roomTitle(String number) {
    return 'KAMAR $number';
  }

  @override
  String get roomLocked => 'Kamar terkunci';

  @override
  String get roomUnlockLater =>
      'Kamar ini akan tersedia melalui progres permainan.';

  @override
  String roomUnlockRequirement(int cost, int level) {
    return 'Memerlukan $cost koin dan level pemain $level.';
  }

  @override
  String get unlockRoom => 'Buka kamar';

  @override
  String get roomUpgrades => 'Peningkatan kamar';

  @override
  String get comfortAttribute => 'Kenyamanan';

  @override
  String get silenceAttribute => 'Keheningan';

  @override
  String get mysticalAttribute => 'Afinitas mistis';

  @override
  String get durabilityAttribute => 'Ketahanan';

  @override
  String upgradeCost(int cost) {
    return 'Tingkatkan · $cost koin';
  }

  @override
  String get maximumLevel => 'MAKS';

  @override
  String get furnitureSlots => 'Slot furnitur';

  @override
  String get primarySlot => 'Utama';

  @override
  String get decorationSlot => 'Dekorasi';

  @override
  String get emptySlot => 'Kosong';

  @override
  String furnitureSlotValue(String slot, String item) {
    return '$slot: $item';
  }

  @override
  String get chooseFurniture => 'Pilih';

  @override
  String happinessDetail(int happiness, String mood) {
    return 'Kebahagiaan: $happiness ($mood)';
  }

  @override
  String neighborCompatibility(int modifier) {
    return 'Kompatibilitas tetangga: $modifier';
  }

  @override
  String tenantLabel(String name) {
    return 'Penghuni: $name';
  }

  @override
  String get vacantTenant => 'Penghuni: Kosong';

  @override
  String get happinessBreakdownTitle => 'Rincian kebahagiaan';

  @override
  String happinessComponent(String label, int value) {
    return '$label: $value';
  }

  @override
  String get baseHappinessLabel => 'Dasar';

  @override
  String get roomPreferenceLabel => 'Preferensi kamar';

  @override
  String get furniturePreferenceLabel => 'Furnitur';

  @override
  String get neighborLabel => 'Tetangga';

  @override
  String get eventLabel => 'Peristiwa';

  @override
  String get viewGhostProfile => 'Lihat profil hantu';

  @override
  String ghostProfileTitle(String name) {
    return 'PROFIL $name';
  }

  @override
  String currentRoom(String number) {
    return 'Kamar saat ini: $number';
  }

  @override
  String get unassignedGhost => 'Belum ditempatkan di kamar';

  @override
  String baseRent(int amount) {
    return 'Sewa dasar: $amount / menit';
  }

  @override
  String likes(String tags) {
    return 'Suka: $tags';
  }

  @override
  String dislikes(String name) {
    return 'Tidak suka: $name';
  }

  @override
  String ability(String description) {
    return 'Kemampuan: $description';
  }

  @override
  String get archetypePocong => 'Si Pelompat Gelisah';

  @override
  String get archetypeKuntilanak => 'Si Tetangga Dramatis';

  @override
  String get archetypeTuyul => 'Si Pengumpul Usil';

  @override
  String get archetypeGenderuwo => 'Si Raksasa Lembut';

  @override
  String get abilityLostCoins =>
      'Menemukan 30 koin setiap 10 menit aktif saat kebahagiaan 80+';

  @override
  String get abilityNeighborhoodReputation =>
      '+1 reputasi setiap 10 menit aktif saat kebahagiaan 80+';

  @override
  String get abilityBaseRentBonus => '+15% sewa dasar saat kebahagiaan 60+';

  @override
  String get abilityRepairDiscount =>
      'Diskon perbaikan 25% saat kebahagiaan 60+';

  @override
  String get moveTenant => 'Pindahkan penghuni';

  @override
  String get chooseDestination => 'Pilih kamar tujuan';

  @override
  String vacantRoom(String number) {
    return 'Kamar $number — kosong';
  }

  @override
  String occupiedRoom(String number) {
    return 'Kamar $number — terisi';
  }

  @override
  String get confirmSwapTitle => 'Tukar penghuni kamar?';

  @override
  String confirmSwapBody(String number) {
    return 'Kamar $number sudah terisi. Tukar kedua penghuni?';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get confirmSwap => 'Tukar penghuni';

  @override
  String get moodHappy => 'Senang';

  @override
  String get moodComfortable => 'Nyaman';

  @override
  String get moodUnhappy => 'Tidak senang';

  @override
  String get moodAngry => 'Marah';

  @override
  String get complaintTitle => 'POCONG TIDAK BISA TIDUR!';

  @override
  String get complaintBody =>
      'Tuyul terus menghitung koin keras-keras di kamar sebelah. Pocong sudah kesal. Apa yang harus dilakukan?';

  @override
  String get installSoundproofing => 'Pasang peredam';

  @override
  String get soundproofingEffect => '−50 koin, Pocong +20 bahagia';

  @override
  String get askTuyulCalm => 'Minta Tuyul tenang';

  @override
  String get askTuyulCalmEffect => 'Pocong +10, Tuyul −10 bahagia';

  @override
  String get peaceOffering => 'Kasih uang damai';

  @override
  String get peaceOfferingEffect => '−25 koin, keduanya +5 bahagia';

  @override
  String complaintResolvedMessage(int happiness) {
    return 'Keluhan selesai. Pocong sekarang $happiness bahagia.';
  }

  @override
  String activeIncident(String title) {
    return 'Insiden: $title';
  }

  @override
  String incidentConsequencePreview(String effects) {
    return 'Dampak: $effects';
  }

  @override
  String incidentEffectCoins(String value) {
    return '$value koin';
  }

  @override
  String incidentEffectHappiness(String ghost, String value) {
    return '$ghost $value bahagia';
  }

  @override
  String incidentEffectChaos(String value) {
    return '$value kekacauan';
  }

  @override
  String incidentEffectReputation(String value) {
    return '$value reputasi';
  }

  @override
  String get incidentNotEnoughCoins => 'Koin tidak cukup';

  @override
  String get incidentResolvedTitle => 'INSIDEN SELESAI';

  @override
  String get continueLabel => 'Lanjut';

  @override
  String get repairRequired => 'Kamar perlu diperbaiki';

  @override
  String repairRoom(int cost) {
    return 'Perbaiki · $cost koin';
  }

  @override
  String get tutorialOpeningTitle => 'KONTRAKAN BARUMU';

  @override
  String get tutorialOpeningBody =>
      'Kamu mewarisi kontrakan yang kelihatannya terbengkalai. Pocong sudah tinggal gratis di sini—sekarang waktunya diresmikan.';

  @override
  String get tutorialPlacePocongTitle => 'SIAPKAN KAMAR PERTAMA';

  @override
  String get tutorialPlacePocongBody =>
      'Koin Arwah membuat kontrakan tetap berjalan. Tempatkan Pocong di Kamar 1 untuk mulai menerima sewa.';

  @override
  String get tutorialPlacePocongAction => 'Tempatkan Pocong';

  @override
  String get tutorialCollectRentTitle => 'AMBIL SEWA PERTAMA';

  @override
  String get tutorialCollectRentBody =>
      'Sewa pertama Pocong sudah siap. Gunakan Ambil Semua di bawah.';

  @override
  String get tutorialKuntilanakTitle => 'KENALAN DENGAN KUNTILANAK';

  @override
  String get tutorialKuntilanakBody =>
      'Setiap hantu punya preferensi kamar dan tetangga. Tempatkan Kuntilanak di Kamar 2.';

  @override
  String get tutorialPlaceKuntilanakAction => 'Tempatkan Kuntilanak';

  @override
  String get tutorialIncidentTitle => 'PAK RT DATANG';

  @override
  String get tutorialIncidentBody =>
      'Sebuah keluhan perlu keputusanmu. Buka insiden di bawah dan pilih konsekuensinya.';

  @override
  String get tutorialLockedRoomTitle => 'MASIH ADA KAMAR LAIN';

  @override
  String get tutorialLockedRoomBody =>
      'Kamar lantai atas akan terbuka lewat misi berikutnya. Kontrakanmu kini siap dimainkan.';

  @override
  String get tutorialFinish => 'Lanjut bermain';

  @override
  String mysticalCrystals(int count) {
    return '$count Kristal';
  }

  @override
  String get missionsTitle => 'MISI';

  @override
  String missionRewardSummary(int coins, int experience, int crystals) {
    return '+$coins koin · +$experience XP · +$crystals kristal';
  }

  @override
  String get missionClaim => 'Klaim';

  @override
  String get missionClaimed => 'Diklaim';

  @override
  String get missionInProgress => 'Belum selesai';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'Bahasa Inggris';

  @override
  String get audioSettingsTitle => 'Pengaturan audio';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get privacySettingsTitle => 'Privasi';

  @override
  String get privacyOfflineExplanation =>
      'Analitik dan laporan kerusakan bersifat opsional. Game offline tetap dapat dimainkan saat dimatikan atau tidak tersedia.';

  @override
  String get analyticsConsentLabel => 'Bagikan analitik permainan anonim';

  @override
  String get errorReportingConsentLabel =>
      'Bagikan laporan kerusakan dan kesalahan';

  @override
  String get adPrivacyOptionsLabel => 'Kelola pilihan privasi iklan';

  @override
  String get privacyPolicyLabel => 'Baca kebijakan privasi';

  @override
  String get privacyPolicyTitle => 'Kebijakan privasi';

  @override
  String get privacyPolicyBody =>
      'Berlaku 14 Oktober 2026. Hantu Kontrakan disediakan oleh PT Indesya Karya Digital. Progres permainan, keadaan ekonomi, pengaturan, bahasa, dan pilihan persetujuan disimpan secara lokal di perangkat ini. Game tidak memiliki akun pemain atau penyimpanan cloud. Data lokal tersimpan sampai Anda mengatur ulang game, menghapus data aplikasi, atau menghapus aplikasi. Analitik dan laporan kerusakan eksternal bersifat terpisah, nonaktif secara bawaan, dan saat ini belum memakai penyedia layanan. Iklan berhadiah opsional menggunakan Google Mobile Ads dan UMP; Google dan mitranya dapat memproses pengenal perangkat atau iklan, persetujuan, informasi IP/jaringan, perkiraan lokasi dari jaringan, interaksi iklan, dan diagnostik sesuai kebijakan mereka. Permainan offline inti tidak mewajibkan menonton iklan. Kami tidak menjual data pemain. Kontak: support@indesyakaryadigital.com. Kebijakan lengkap terbaru diterbitkan di situs web Indesya Karya Digital.';

  @override
  String get musicMutedLabel => 'Bisukan musik';

  @override
  String get soundMutedLabel => 'Bisukan efek suara';

  @override
  String get musicVolumeLabel => 'Volume musik';

  @override
  String get soundVolumeLabel => 'Volume efek suara';

  @override
  String get closeLabel => 'Tutup';

  @override
  String roomCanvasHappiness(int value) {
    return 'Bahagia $value';
  }

  @override
  String get roomCanvasLocked => 'TERKUNCI';

  @override
  String get tagQuiet => 'Tenang';

  @override
  String get tagPlant => 'Tanaman';

  @override
  String get tagDecorated => 'Berdekorasi';

  @override
  String get tagMystical => 'Mistis';

  @override
  String get tagShiny => 'Berkilau';

  @override
  String get tagSturdy => 'Kokoh';

  @override
  String get furnitureBed => 'Tempat tidur';

  @override
  String get furnitureReinforcedShelf => 'Rak kokoh';

  @override
  String get furnitureFan => 'Kipas';

  @override
  String get furnitureDresser => 'Lemari';

  @override
  String get furnitureDoor => 'Pintu';

  @override
  String get furnitureLamp => 'Lampu';

  @override
  String get furniturePlant => 'Tanaman';

  @override
  String get furnitureLantern => 'Lentera';

  @override
  String get furnitureCurtain => 'Tirai';

  @override
  String get furnitureRug => 'Karpet';

  @override
  String get furnitureWallCharm => 'Jimat dinding';

  @override
  String get furnitureShinyTrinket => 'Pernak-pernik berkilau';

  @override
  String get navigationHome => 'Kontrakan';

  @override
  String get navigationGhosts => 'Hantu';

  @override
  String get navigationShop => 'Toko';

  @override
  String get moreActionsLabel => 'Aksi lainnya';

  @override
  String get propertyActionsTitle => 'Kamar dan peningkatan';

  @override
  String get offlineReturnTitle => 'Selamat datang kembali!';

  @override
  String offlineReturnBody(Object coins) {
    return 'Para penyewa menghasilkan $coins koin saat kamu pergi.';
  }

  @override
  String get collectLabel => 'Ambil';
}
