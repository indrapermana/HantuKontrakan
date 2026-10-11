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

  /// No description provided for @swapTenant.
  ///
  /// In id, this message translates to:
  /// **'Tukar penghuni kamar'**
  String get swapTenant;

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
