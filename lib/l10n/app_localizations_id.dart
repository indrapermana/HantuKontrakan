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
}
