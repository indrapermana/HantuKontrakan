import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Hantu Kontrakan'**
  String get appTitle;

  /// No description provided for @appTitleUppercase.
  ///
  /// In id, this message translates to:
  /// **'HANTU KONTRAKAN'**
  String get appTitleUppercase;

  /// No description provided for @spiritCoins.
  ///
  /// In id, this message translates to:
  /// **'{count} Koin Arwah'**
  String spiritCoins(int count);

  /// No description provided for @collectAllRent.
  ///
  /// In id, this message translates to:
  /// **'Ambil Semua · {count} koin'**
  String collectAllRent(int count);

  /// No description provided for @ghostHappinessSummary.
  ///
  /// In id, this message translates to:
  /// **'{ghostName} {happiness}'**
  String ghostHappinessSummary(String ghostName, int happiness);

  /// No description provided for @pendingComplaint.
  ///
  /// In id, this message translates to:
  /// **'Keluhan: Pocong terganggu Tuyul'**
  String get pendingComplaint;

  /// No description provided for @resolvedComplaint.
  ///
  /// In id, this message translates to:
  /// **'Keluhan selesai dan tersimpan'**
  String get resolvedComplaint;

  /// No description provided for @roomTitle.
  ///
  /// In id, this message translates to:
  /// **'KAMAR {number}'**
  String roomTitle(String number);

  /// No description provided for @roomLocked.
  ///
  /// In id, this message translates to:
  /// **'Kamar terkunci'**
  String get roomLocked;

  /// No description provided for @roomUnlockLater.
  ///
  /// In id, this message translates to:
  /// **'Kamar ini akan tersedia melalui progres permainan.'**
  String get roomUnlockLater;

  /// No description provided for @roomUnlockRequirement.
  ///
  /// In id, this message translates to:
  /// **'Memerlukan {cost} koin dan level pemain {level}.'**
  String roomUnlockRequirement(int cost, int level);

  /// No description provided for @unlockRoom.
  ///
  /// In id, this message translates to:
  /// **'Buka kamar'**
  String get unlockRoom;

  /// No description provided for @roomUpgrades.
  ///
  /// In id, this message translates to:
  /// **'Peningkatan kamar'**
  String get roomUpgrades;

  /// No description provided for @comfortAttribute.
  ///
  /// In id, this message translates to:
  /// **'Kenyamanan'**
  String get comfortAttribute;

  /// No description provided for @silenceAttribute.
  ///
  /// In id, this message translates to:
  /// **'Keheningan'**
  String get silenceAttribute;

  /// No description provided for @mysticalAttribute.
  ///
  /// In id, this message translates to:
  /// **'Afinitas mistis'**
  String get mysticalAttribute;

  /// No description provided for @durabilityAttribute.
  ///
  /// In id, this message translates to:
  /// **'Ketahanan'**
  String get durabilityAttribute;

  /// No description provided for @upgradeCost.
  ///
  /// In id, this message translates to:
  /// **'Tingkatkan · {cost} koin'**
  String upgradeCost(int cost);

  /// No description provided for @maximumLevel.
  ///
  /// In id, this message translates to:
  /// **'MAKS'**
  String get maximumLevel;

  /// No description provided for @furnitureSlots.
  ///
  /// In id, this message translates to:
  /// **'Slot furnitur'**
  String get furnitureSlots;

  /// No description provided for @primarySlot.
  ///
  /// In id, this message translates to:
  /// **'Utama'**
  String get primarySlot;

  /// No description provided for @decorationSlot.
  ///
  /// In id, this message translates to:
  /// **'Dekorasi'**
  String get decorationSlot;

  /// No description provided for @emptySlot.
  ///
  /// In id, this message translates to:
  /// **'Kosong'**
  String get emptySlot;

  /// No description provided for @furnitureSlotValue.
  ///
  /// In id, this message translates to:
  /// **'{slot}: {item}'**
  String furnitureSlotValue(String slot, String item);

  /// No description provided for @chooseFurniture.
  ///
  /// In id, this message translates to:
  /// **'Pilih'**
  String get chooseFurniture;

  /// No description provided for @happinessDetail.
  ///
  /// In id, this message translates to:
  /// **'Kebahagiaan: {happiness} ({mood})'**
  String happinessDetail(int happiness, String mood);

  /// No description provided for @neighborCompatibility.
  ///
  /// In id, this message translates to:
  /// **'Kompatibilitas tetangga: {modifier}'**
  String neighborCompatibility(int modifier);

  /// No description provided for @tenantLabel.
  ///
  /// In id, this message translates to:
  /// **'Penghuni: {name}'**
  String tenantLabel(String name);

  /// No description provided for @vacantTenant.
  ///
  /// In id, this message translates to:
  /// **'Penghuni: Kosong'**
  String get vacantTenant;

  /// No description provided for @happinessBreakdownTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian kebahagiaan'**
  String get happinessBreakdownTitle;

  /// No description provided for @happinessComponent.
  ///
  /// In id, this message translates to:
  /// **'{label}: {value}'**
  String happinessComponent(String label, int value);

  /// No description provided for @baseHappinessLabel.
  ///
  /// In id, this message translates to:
  /// **'Dasar'**
  String get baseHappinessLabel;

  /// No description provided for @roomPreferenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Preferensi kamar'**
  String get roomPreferenceLabel;

  /// No description provided for @furniturePreferenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Furnitur'**
  String get furniturePreferenceLabel;

  /// No description provided for @neighborLabel.
  ///
  /// In id, this message translates to:
  /// **'Tetangga'**
  String get neighborLabel;

  /// No description provided for @eventLabel.
  ///
  /// In id, this message translates to:
  /// **'Peristiwa'**
  String get eventLabel;

  /// No description provided for @viewGhostProfile.
  ///
  /// In id, this message translates to:
  /// **'Lihat profil hantu'**
  String get viewGhostProfile;

  /// No description provided for @ghostProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'PROFIL {name}'**
  String ghostProfileTitle(String name);

  /// No description provided for @currentRoom.
  ///
  /// In id, this message translates to:
  /// **'Kamar saat ini: {number}'**
  String currentRoom(String number);

  /// No description provided for @unassignedGhost.
  ///
  /// In id, this message translates to:
  /// **'Belum ditempatkan di kamar'**
  String get unassignedGhost;

  /// No description provided for @baseRent.
  ///
  /// In id, this message translates to:
  /// **'Sewa dasar: {amount} / menit'**
  String baseRent(int amount);

  /// No description provided for @likes.
  ///
  /// In id, this message translates to:
  /// **'Suka: {tags}'**
  String likes(String tags);

  /// No description provided for @dislikes.
  ///
  /// In id, this message translates to:
  /// **'Tidak suka: {name}'**
  String dislikes(String name);

  /// No description provided for @ability.
  ///
  /// In id, this message translates to:
  /// **'Kemampuan: {description}'**
  String ability(String description);

  /// No description provided for @archetypePocong.
  ///
  /// In id, this message translates to:
  /// **'Si Pelompat Gelisah'**
  String get archetypePocong;

  /// No description provided for @archetypeKuntilanak.
  ///
  /// In id, this message translates to:
  /// **'Si Tetangga Dramatis'**
  String get archetypeKuntilanak;

  /// No description provided for @archetypeTuyul.
  ///
  /// In id, this message translates to:
  /// **'Si Pengumpul Usil'**
  String get archetypeTuyul;

  /// No description provided for @archetypeGenderuwo.
  ///
  /// In id, this message translates to:
  /// **'Si Raksasa Lembut'**
  String get archetypeGenderuwo;

  /// No description provided for @abilityLostCoins.
  ///
  /// In id, this message translates to:
  /// **'Menemukan 30 koin setiap 10 menit aktif saat kebahagiaan 80+'**
  String get abilityLostCoins;

  /// No description provided for @abilityNeighborhoodReputation.
  ///
  /// In id, this message translates to:
  /// **'+1 reputasi setiap 10 menit aktif saat kebahagiaan 80+'**
  String get abilityNeighborhoodReputation;

  /// No description provided for @abilityBaseRentBonus.
  ///
  /// In id, this message translates to:
  /// **'+15% sewa dasar saat kebahagiaan 60+'**
  String get abilityBaseRentBonus;

  /// No description provided for @abilityRepairDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon perbaikan 25% saat kebahagiaan 60+'**
  String get abilityRepairDiscount;

  /// No description provided for @moveTenant.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan penghuni'**
  String get moveTenant;

  /// No description provided for @chooseDestination.
  ///
  /// In id, this message translates to:
  /// **'Pilih kamar tujuan'**
  String get chooseDestination;

  /// No description provided for @vacantRoom.
  ///
  /// In id, this message translates to:
  /// **'Kamar {number} — kosong'**
  String vacantRoom(String number);

  /// No description provided for @occupiedRoom.
  ///
  /// In id, this message translates to:
  /// **'Kamar {number} — terisi'**
  String occupiedRoom(String number);

  /// No description provided for @confirmSwapTitle.
  ///
  /// In id, this message translates to:
  /// **'Tukar penghuni kamar?'**
  String get confirmSwapTitle;

  /// No description provided for @confirmSwapBody.
  ///
  /// In id, this message translates to:
  /// **'Kamar {number} sudah terisi. Tukar kedua penghuni?'**
  String confirmSwapBody(String number);

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @confirmSwap.
  ///
  /// In id, this message translates to:
  /// **'Tukar penghuni'**
  String get confirmSwap;

  /// No description provided for @moodHappy.
  ///
  /// In id, this message translates to:
  /// **'Senang'**
  String get moodHappy;

  /// No description provided for @moodComfortable.
  ///
  /// In id, this message translates to:
  /// **'Nyaman'**
  String get moodComfortable;

  /// No description provided for @moodUnhappy.
  ///
  /// In id, this message translates to:
  /// **'Tidak senang'**
  String get moodUnhappy;

  /// No description provided for @moodAngry.
  ///
  /// In id, this message translates to:
  /// **'Marah'**
  String get moodAngry;

  /// No description provided for @complaintTitle.
  ///
  /// In id, this message translates to:
  /// **'POCONG TIDAK BISA TIDUR!'**
  String get complaintTitle;

  /// No description provided for @complaintBody.
  ///
  /// In id, this message translates to:
  /// **'Tuyul terus menghitung koin keras-keras di kamar sebelah. Pocong sudah kesal. Apa yang harus dilakukan?'**
  String get complaintBody;

  /// No description provided for @installSoundproofing.
  ///
  /// In id, this message translates to:
  /// **'Pasang peredam'**
  String get installSoundproofing;

  /// No description provided for @soundproofingEffect.
  ///
  /// In id, this message translates to:
  /// **'−50 koin, Pocong +20 bahagia'**
  String get soundproofingEffect;

  /// No description provided for @askTuyulCalm.
  ///
  /// In id, this message translates to:
  /// **'Minta Tuyul tenang'**
  String get askTuyulCalm;

  /// No description provided for @askTuyulCalmEffect.
  ///
  /// In id, this message translates to:
  /// **'Pocong +10, Tuyul −10 bahagia'**
  String get askTuyulCalmEffect;

  /// No description provided for @peaceOffering.
  ///
  /// In id, this message translates to:
  /// **'Kasih uang damai'**
  String get peaceOffering;

  /// No description provided for @peaceOfferingEffect.
  ///
  /// In id, this message translates to:
  /// **'−25 koin, keduanya +5 bahagia'**
  String get peaceOfferingEffect;

  /// No description provided for @complaintResolvedMessage.
  ///
  /// In id, this message translates to:
  /// **'Keluhan selesai. Pocong sekarang {happiness} bahagia.'**
  String complaintResolvedMessage(int happiness);

  /// No description provided for @activeIncident.
  ///
  /// In id, this message translates to:
  /// **'Insiden: {title}'**
  String activeIncident(String title);

  /// No description provided for @incidentConsequencePreview.
  ///
  /// In id, this message translates to:
  /// **'Dampak: {effects}'**
  String incidentConsequencePreview(String effects);

  /// No description provided for @incidentEffectCoins.
  ///
  /// In id, this message translates to:
  /// **'{value} koin'**
  String incidentEffectCoins(String value);

  /// No description provided for @incidentEffectHappiness.
  ///
  /// In id, this message translates to:
  /// **'{ghost} {value} bahagia'**
  String incidentEffectHappiness(String ghost, String value);

  /// No description provided for @incidentEffectChaos.
  ///
  /// In id, this message translates to:
  /// **'{value} kekacauan'**
  String incidentEffectChaos(String value);

  /// No description provided for @incidentEffectReputation.
  ///
  /// In id, this message translates to:
  /// **'{value} reputasi'**
  String incidentEffectReputation(String value);

  /// No description provided for @incidentNotEnoughCoins.
  ///
  /// In id, this message translates to:
  /// **'Koin tidak cukup'**
  String get incidentNotEnoughCoins;

  /// No description provided for @incidentResolvedTitle.
  ///
  /// In id, this message translates to:
  /// **'INSIDEN SELESAI'**
  String get incidentResolvedTitle;

  /// No description provided for @continueLabel.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get continueLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
