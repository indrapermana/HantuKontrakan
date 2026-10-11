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
  String happinessDetail(int happiness, String mood) {
    return 'Kebahagiaan: $happiness ($mood)';
  }

  @override
  String neighborCompatibility(int modifier) {
    return 'Kompatibilitas tetangga: $modifier';
  }

  @override
  String get swapTenant => 'Tukar penghuni kamar';

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
