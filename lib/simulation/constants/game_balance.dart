abstract final class GameBalance {
  static const int initialCoins = 200;
  static const int initialChaos = 40;
  static const int minimumChaos = 0;
  static const int maximumChaos = 100;
  static const int initialPlayerLevel = 1;
  static const int initialReputation = 60;
  static const int maximumReputation = 100;
  static const int defaultRandomSeed = 20261011;
  static const int debugTickSeconds = 1;
  static const int microcoinsPerCoin = 1000000;
  static const int secondsPerMinute = 60;
  static const int millisecondsPerMinute = 60000;
  static const int offlineEarningsPercent = 50;
  static const int maximumOfflineMinutes = 240;
  static const int periodicAbilityIntervalSeconds = 600;
  static const int chaosIntervalSeconds = 600;
  static const int chaosNaturalReductionPerInterval = 4;
  static const int eventModifierDurationSeconds = 600;
  static const int incidentCheckIntervalSeconds = 60;
  static const int incidentCooldownSeconds = 180;
  static const int incidentRollingWindowSeconds = 600;
  static const int maximumIncidentsPerRollingWindow = 3;
  static const int incidentChanceScale = 10000;
  static const int incidentBaseChance = 400;
  static const int incidentChancePerChaos = 20;
  static const int maximumIncidentChance = 3500;
  static const int incidentRecentHistoryLength = 2;
  static const int periodicAbilityMinimumHappiness = 80;
  static const int pocongAbilityCoinReward = 30;
  static const int kuntilanakAbilityReputationReward = 1;
  static const int conditionalAbilityMinimumHappiness = 60;
  static const int genderuwoRepairCostPercent = 75;
  static const int tuyulBaseRentBonusPercent = 15;
  static const int baseHappiness = 50;
  static const Map<int, int> roomTagMatchHappinessByLevel = {1: 10, 2: 15};
  static const Map<int, int> roomTagMismatchHappinessByLevel = {1: -5, 2: -10};
  static const int roomPreferenceMinimum = -20;
  static const int roomPreferenceMaximum = 20;
  static const int furnitureTagMatchHappiness = 10;
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
