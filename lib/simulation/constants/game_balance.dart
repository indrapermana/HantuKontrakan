abstract final class GameBalance {
  static const int initialCoins = 200;
  static const int initialChaos = 40;
  static const int initialPlayerLevel = 1;
  static const int defaultRandomSeed = 20261011;
  static const int debugTickSeconds = 1;
  static const int baseHappiness = 50;
  static const Map<int, int> roomTagMatchHappinessByLevel = {1: 10, 2: 15};
  static const Map<int, int> roomTagMismatchHappinessByLevel = {1: -5, 2: -10};
  static const int roomPreferenceMinimum = -20;
  static const int roomPreferenceMaximum = 20;
  static const int furnitureTagMatchHappiness = 5;
  static const int furnitureTagMismatchHappiness = -2;
  static const int furniturePreferenceMinimum = -10;
  static const int furniturePreferenceMaximum = 10;
  static const int compatibilityMinimum = -20;
  static const int compatibilityMaximum = 15;
  static const int eventMinimum = -20;
  static const int eventMaximum = 20;
  static const int maximumRoomUpgradeLevel = 2;
  static const Map<int, int> roomUpgradeCosts = {0: 100, 1: 200};
  static const Map<String, int> roomUnlockCosts = {
    'room_03': 400,
    'room_04': 800,
  };
  static const Map<String, int> roomUnlockLevels = {'room_03': 3, 'room_04': 5};

  static const String p0ComplaintResolutionId = 'p0_complaint_resolution';
  static const int soundproofingCoinCost = 50;
  static const int soundproofingPocongHappiness = 20;
  static const int calmTuyulPocongHappiness = 10;
  static const int calmTuyulTuyulHappiness = -10;
  static const int peaceOfferingCoinCost = 25;
  static const int peaceOfferingHappiness = 5;
}
