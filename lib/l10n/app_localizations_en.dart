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
  String collectAllRent(int count) {
    return 'Collect All · $count coins';
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
  String get roomLocked => 'Room locked';

  @override
  String get roomUnlockLater =>
      'This room will become available through game progression.';

  @override
  String roomUnlockRequirement(int cost, int level) {
    return 'Requires $cost coins and player level $level.';
  }

  @override
  String get unlockRoom => 'Unlock room';

  @override
  String get roomUpgrades => 'Room upgrades';

  @override
  String get comfortAttribute => 'Comfort';

  @override
  String get silenceAttribute => 'Silence';

  @override
  String get mysticalAttribute => 'Mystical affinity';

  @override
  String get durabilityAttribute => 'Durability';

  @override
  String upgradeCost(int cost) {
    return 'Upgrade · $cost coins';
  }

  @override
  String get maximumLevel => 'MAX';

  @override
  String get furnitureSlots => 'Furniture slots';

  @override
  String get primarySlot => 'Primary';

  @override
  String get decorationSlot => 'Decoration';

  @override
  String get emptySlot => 'Empty';

  @override
  String furnitureSlotValue(String slot, String item) {
    return '$slot: $item';
  }

  @override
  String get chooseFurniture => 'Choose';

  @override
  String happinessDetail(int happiness, String mood) {
    return 'Happiness: $happiness ($mood)';
  }

  @override
  String neighborCompatibility(int modifier) {
    return 'Neighbor compatibility: $modifier';
  }

  @override
  String tenantLabel(String name) {
    return 'Tenant: $name';
  }

  @override
  String get vacantTenant => 'Tenant: Vacant';

  @override
  String get happinessBreakdownTitle => 'Happiness breakdown';

  @override
  String happinessComponent(String label, int value) {
    return '$label: $value';
  }

  @override
  String get baseHappinessLabel => 'Base';

  @override
  String get roomPreferenceLabel => 'Room preference';

  @override
  String get furniturePreferenceLabel => 'Furniture';

  @override
  String get neighborLabel => 'Neighbors';

  @override
  String get eventLabel => 'Events';

  @override
  String get viewGhostProfile => 'View ghost profile';

  @override
  String ghostProfileTitle(String name) {
    return '$name PROFILE';
  }

  @override
  String currentRoom(String number) {
    return 'Current room: $number';
  }

  @override
  String get unassignedGhost => 'Not assigned to a room';

  @override
  String baseRent(int amount) {
    return 'Base rent: $amount / min';
  }

  @override
  String likes(String tags) {
    return 'Likes: $tags';
  }

  @override
  String dislikes(String name) {
    return 'Dislikes: $name';
  }

  @override
  String ability(String description) {
    return 'Ability: $description';
  }

  @override
  String get archetypePocong => 'The Restless Jumper';

  @override
  String get archetypeKuntilanak => 'The Dramatic Neighbor';

  @override
  String get archetypeTuyul => 'The Mischievous Collector';

  @override
  String get archetypeGenderuwo => 'The Gentle Giant';

  @override
  String get abilityLostCoins =>
      'Find 30 coins every 10 active minutes at 80+ happiness';

  @override
  String get abilityNeighborhoodReputation =>
      '+1 reputation every 10 active minutes at 80+ happiness';

  @override
  String get abilityBaseRentBonus => '+15% base rent at 60+ happiness';

  @override
  String get abilityRepairDiscount => '25% repair discount at 60+ happiness';

  @override
  String get moveTenant => 'Move tenant';

  @override
  String get chooseDestination => 'Choose destination room';

  @override
  String vacantRoom(String number) {
    return 'Room $number — vacant';
  }

  @override
  String occupiedRoom(String number) {
    return 'Room $number — occupied';
  }

  @override
  String get confirmSwapTitle => 'Swap room tenants?';

  @override
  String confirmSwapBody(String number) {
    return 'Room $number is occupied. Swap both tenants?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmSwap => 'Swap tenants';

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

  @override
  String activeIncident(String title) {
    return 'Incident: $title';
  }

  @override
  String incidentConsequencePreview(String effects) {
    return 'Effects: $effects';
  }

  @override
  String incidentEffectCoins(String value) {
    return '$value coins';
  }

  @override
  String incidentEffectHappiness(String ghost, String value) {
    return '$ghost $value happiness';
  }

  @override
  String incidentEffectChaos(String value) {
    return '$value chaos';
  }

  @override
  String incidentEffectReputation(String value) {
    return '$value reputation';
  }

  @override
  String get incidentNotEnoughCoins => 'Not enough coins';

  @override
  String get incidentResolvedTitle => 'INCIDENT RESOLVED';

  @override
  String get continueLabel => 'Continue';

  @override
  String get repairRequired => 'Room needs repair';

  @override
  String repairRoom(int cost) {
    return 'Repair · $cost coins';
  }

  @override
  String get tutorialOpeningTitle => 'YOUR NEW KONTRAKAN';

  @override
  String get tutorialOpeningBody =>
      'You inherited an apparently abandoned kontrakan. Pocong has already been staying here rent-free—time to make it official.';

  @override
  String get tutorialPlacePocongTitle => 'PREPARE THE FIRST ROOM';

  @override
  String get tutorialPlacePocongBody =>
      'Koin Arwah keeps the kontrakan running. Place Pocong in Room 1 to start earning rent.';

  @override
  String get tutorialPlacePocongAction => 'Place Pocong';

  @override
  String get tutorialCollectRentTitle => 'COLLECT YOUR FIRST RENT';

  @override
  String get tutorialCollectRentBody =>
      'Pocong\'s first rent is ready. Use Collect All below.';

  @override
  String get tutorialKuntilanakTitle => 'MEET KUNTILANAK';

  @override
  String get tutorialKuntilanakBody =>
      'Every ghost prefers different rooms and neighbors. Place Kuntilanak in Room 2.';

  @override
  String get tutorialPlaceKuntilanakAction => 'Place Kuntilanak';

  @override
  String get tutorialIncidentTitle => 'PAK RT IS HERE';

  @override
  String get tutorialIncidentBody =>
      'A complaint needs your decision. Open the incident below and choose a consequence.';

  @override
  String get tutorialLockedRoomTitle => 'MORE ROOMS AWAIT';

  @override
  String get tutorialLockedRoomBody =>
      'The upstairs rooms unlock through future missions. Your kontrakan is now open for play.';

  @override
  String get tutorialFinish => 'Continue playing';
}
