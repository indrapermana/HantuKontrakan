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
  String rewardedRentButton(int coins, int remaining) {
    return 'Watch test ad · $coins + $coins coins ($remaining/3 left)';
  }

  @override
  String get rewardedRentDailyLimit => 'Daily ad bonus limit reached';

  @override
  String rewardedRentEarned(int coins) {
    return 'Ad reward earned: +$coins bonus coins';
  }

  @override
  String rewardedRentBaseOnly(int coins) {
    return 'Ad unavailable or skipped. $coins base coins were still collected.';
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

  @override
  String mysticalCrystals(int count) {
    return '$count Crystals';
  }

  @override
  String get missionsTitle => 'MISSIONS';

  @override
  String missionRewardSummary(int coins, int experience, int crystals) {
    return '+$coins coins · +$experience XP · +$crystals crystals';
  }

  @override
  String get missionClaim => 'Claim';

  @override
  String get missionClaimed => 'Claimed';

  @override
  String get missionInProgress => 'In progress';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageEnglish => 'English';

  @override
  String get audioSettingsTitle => 'Audio settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get privacySettingsTitle => 'Privacy';

  @override
  String get privacyOfflineExplanation =>
      'Analytics and crash reports are optional. The offline game remains playable when they are off or unavailable.';

  @override
  String get analyticsConsentLabel => 'Share anonymous gameplay analytics';

  @override
  String get errorReportingConsentLabel => 'Share crash and error reports';

  @override
  String get adPrivacyOptionsLabel => 'Manage ad privacy choices';

  @override
  String get privacyPolicyLabel => 'Read privacy policy';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicyBody =>
      'Effective 14 October 2026. Hantu Kontrakan is provided by PT Indesya Karya Digital. Game progress, economy state, settings, language, and consent choices are stored locally on this device. The game has no player account or cloud save. Local data remains until you reset the game, clear app data, or uninstall the app. Optional analytics and external crash reporting are separate, disabled by default, and no provider is currently configured. Optional rewarded ads use Google Mobile Ads and UMP; Google and its partners may process device or advertising identifiers, consent, IP/network information, approximate location inferred from the network, ad interactions, and diagnostics under their policies. Core offline play does not require watching ads. We do not sell player data. Contact: support@indesyakaryadigital.com. The complete current policy is published on the Indesya Karya Digital website.';

  @override
  String get musicMutedLabel => 'Mute music';

  @override
  String get soundMutedLabel => 'Mute sound effects';

  @override
  String get musicVolumeLabel => 'Music volume';

  @override
  String get soundVolumeLabel => 'Sound effects volume';

  @override
  String get closeLabel => 'Close';

  @override
  String roomCanvasHappiness(int value) {
    return 'Happy $value';
  }

  @override
  String get roomCanvasLocked => 'LOCKED';

  @override
  String get tagQuiet => 'Quiet';

  @override
  String get tagPlant => 'Plant';

  @override
  String get tagDecorated => 'Decorated';

  @override
  String get tagMystical => 'Mystical';

  @override
  String get tagShiny => 'Shiny';

  @override
  String get tagSturdy => 'Sturdy';

  @override
  String get furnitureBed => 'Bed';

  @override
  String get furnitureReinforcedShelf => 'Reinforced shelf';

  @override
  String get furnitureFan => 'Fan';

  @override
  String get furnitureDresser => 'Dresser';

  @override
  String get furnitureDoor => 'Door';

  @override
  String get furnitureLamp => 'Lamp';

  @override
  String get furniturePlant => 'Plant';

  @override
  String get furnitureLantern => 'Lantern';

  @override
  String get furnitureCurtain => 'Curtain';

  @override
  String get furnitureRug => 'Rug';

  @override
  String get furnitureWallCharm => 'Wall charm';

  @override
  String get furnitureShinyTrinket => 'Shiny trinket';

  @override
  String get navigationHome => 'Kontrakan';

  @override
  String get navigationGhosts => 'Ghosts';

  @override
  String get navigationShop => 'Shop';

  @override
  String get moreActionsLabel => 'More actions';

  @override
  String get propertyActionsTitle => 'Rooms and improvements';

  @override
  String get offlineReturnTitle => 'Welcome back!';

  @override
  String offlineReturnBody(Object coins) {
    return 'Your tenants earned $coins coins while you were away.';
  }

  @override
  String offlineRoomContribution(Object coins, Object number) {
    return 'Room $number: +$coins coins';
  }

  @override
  String get collectLabel => 'Collect';

  @override
  String roomRentBubbleLabel(Object coins, Object number) {
    return 'Collect $coins coins from room $number';
  }

  @override
  String get rentCollectedTitle => 'Rent collected!';

  @override
  String allRentCollected(Object coins) {
    return 'You collected $coins coins from all ready rooms.';
  }

  @override
  String roomRentCollected(Object coins, Object number) {
    return 'Room $number paid $coins coins.';
  }

  @override
  String get chapterOneTitle => 'CHAPTER 1 · FIRST KONTRAKAN';

  @override
  String get dailyGoalsTitle => 'TODAY\'S TASKS';

  @override
  String get dailyGoalsSubtitle =>
      'Three fresh reasons to check on your tenants every day.';

  @override
  String dailyGoalProgress(int current, int target) {
    return '$current / $target';
  }

  @override
  String get dailyTenantRequest => 'Tenant request';

  @override
  String get dailyChestTitle => 'Daily reward chest';

  @override
  String get dailyChestDescription =>
      'Claim all three daily task rewards to open this chest.';

  @override
  String get dailyChestClaim => 'Open chest';

  @override
  String get dailyChestLocked => 'Complete all tasks';

  @override
  String get dailyChestClaimed => 'Opened today';

  @override
  String dailyScheduleLabel(String dayKey) {
    return 'Schedule: $dayKey';
  }

  @override
  String roomTier(int tier) {
    return 'ROOM TIER $tier';
  }

  @override
  String get propertyPortfolioTitle => 'PROPERTY PORTFOLIO';

  @override
  String get propertyFirstName => 'First Kontrakan';

  @override
  String get propertySecondName => 'Night Market Lodge';

  @override
  String get propertyActive => 'Active property';

  @override
  String get propertyVisit => 'Visit';

  @override
  String get propertyLocked =>
      'Fill all four rooms in the First Kontrakan to expand.';

  @override
  String get propertyUnlock => 'Open expansion';

  @override
  String get propertyReady => 'Expansion ready — no purchase required.';

  @override
  String get ownedFurnitureTitle => 'OWNED FURNITURE';

  @override
  String get crystalFurnitureTitle => 'MYSTICAL WORKSHOP';

  @override
  String buyForCrystals(int cost) {
    return 'Get for $cost crystals';
  }

  @override
  String get furnitureMoonMirror => 'Moon mirror';

  @override
  String get furnitureSpiritRadio => 'Spirit radio';

  @override
  String get ghostStoryReady => 'Story ready';

  @override
  String get ghostStoryComplete => 'Story remembered';

  @override
  String get ghostStoryLocked => 'House this ghost to unlock their story';

  @override
  String get rememberStory => 'Remember story';

  @override
  String get hapticsLabel => 'Haptic feedback';

  @override
  String get hapticsDescription => 'Gentle vibration for important actions';

  @override
  String get reducedMotionLabel => 'Reduce motion';

  @override
  String get reducedMotionDescription =>
      'Use calm feedback without flying particles';

  @override
  String ghostCollectionProgress(int complete, int total) {
    return 'Stories $complete/$total';
  }

  @override
  String get assignTenant => 'Add tenant';

  @override
  String get assignRoom => 'Assign room';

  @override
  String chooseTenantForRoom(String number) {
    return 'CHOOSE TENANT · ROOM $number';
  }

  @override
  String get chooseRoomForTenant => 'CHOOSE A VACANT ROOM';

  @override
  String get noAvailableTenants =>
      'No unlocked unassigned tenant is available yet.';

  @override
  String get noAvailableRooms => 'No vacant unlocked room is available yet.';

  @override
  String levelProgressTitle(int level) {
    return 'LEVEL $level PROGRESS';
  }

  @override
  String levelExperienceProgress(int current, int target) {
    return '$current / $target XP';
  }

  @override
  String get maximumLevelReached => 'Maximum level reached';

  @override
  String nextLevelUnlocks(int level, String unlocks) {
    return 'Level $level unlocks: $unlocks';
  }

  @override
  String nextLevelMoreRewards(int level) {
    return 'Reach level $level for more progression rewards.';
  }

  @override
  String get levelChecklistTitle => 'NEXT USEFUL ACTIONS';

  @override
  String get viewTasks => 'View tasks';

  @override
  String get coinInfoTitle => 'SPIRIT COINS';

  @override
  String coinInfoBody(int coins, String rate) {
    return 'You have $coins coins. Occupied rooms currently earn about $rate coins per minute. Collect rent, then spend coins on rooms and upgrades.';
  }

  @override
  String get crystalInfoTitle => 'MYSTICAL CRYSTALS';

  @override
  String crystalInfoBody(int count) {
    return 'You have $count crystals. Earn more from selected chapter missions and daily rewards, then spend them on optional workshop furniture. No purchase is required.';
  }

  @override
  String get openWorkshop => 'Open workshop';
}
