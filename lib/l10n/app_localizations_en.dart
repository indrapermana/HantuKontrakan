// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hantu Kontrakan';

  @override
  String get appTitleUppercase => 'HANTU KONTRAKAN';

  @override
  String spiritCoins(int count) {
    return '$count Spirit Coins';
  }

  @override
  String ghostHappinessSummary(String ghostName, int happiness) {
    return '$ghostName $happiness';
  }

  @override
  String get pendingComplaint => 'Complaint: Pocong is bothered by Tuyul';

  @override
  String get resolvedComplaint => 'Complaint resolved and saved';

  @override
  String roomTitle(String number) {
    return 'ROOM $number';
  }

  @override
  String happinessDetail(int happiness, String mood) {
    return 'Happiness: $happiness ($mood)';
  }

  @override
  String neighborCompatibility(int modifier) {
    return 'Neighbor compatibility: $modifier';
  }

  @override
  String get swapTenant => 'Swap room tenants';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodComfortable => 'Comfortable';

  @override
  String get moodUnhappy => 'Unhappy';

  @override
  String get moodAngry => 'Angry';

  @override
  String get complaintTitle => 'POCONG CANNOT SLEEP!';

  @override
  String get complaintBody =>
      'Tuyul keeps counting coins loudly in the next room. Pocong is upset. What should be done?';

  @override
  String get installSoundproofing => 'Install soundproofing';

  @override
  String get soundproofingEffect => '−50 coins, Pocong +20 happiness';

  @override
  String get askTuyulCalm => 'Ask Tuyul to quiet down';

  @override
  String get askTuyulCalmEffect => 'Pocong +10, Tuyul −10 happiness';

  @override
  String get peaceOffering => 'Offer peace money';

  @override
  String get peaceOfferingEffect => '−25 coins, both +5 happiness';

  @override
  String complaintResolvedMessage(int happiness) {
    return 'Complaint resolved. Pocong now has $happiness happiness.';
  }
}
