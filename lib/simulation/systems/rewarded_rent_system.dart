import '../constants/game_balance.dart';
import '../models/game_state.dart';
import '../models/rewarded_rent_claim.dart';
import 'tutorial_system.dart';

abstract final class RewardedRentSystem {
  static bool canBegin(GameState state, String localDayKey) =>
      localDayKey.trim().isNotEmpty &&
      state.pendingRewardedRentClaim == null &&
      state.pendingRentMicrocoins >= GameBalance.microcoinsPerCoin &&
      _countForDay(state, localDayKey) <
          GameBalance.maximumRewardedRentBonusesPerDay;

  static GameState begin(GameState state, String claimId, String localDayKey) {
    if (claimId.trim().isEmpty ||
        state.completedRentClaimIds.contains(claimId) ||
        state.completedRewardedRentClaimIds.contains(claimId) ||
        !canBegin(state, localDayKey)) {
      return state;
    }
    final wholeCoins =
        state.pendingRentMicrocoins ~/ GameBalance.microcoinsPerCoin;
    final collected = state.copyWith(
      walletCoins: state.walletCoins + wholeCoins,
      pendingRentMicrocoins:
          state.pendingRentMicrocoins % GameBalance.microcoinsPerCoin,
      completedRentClaimIds: {...state.completedRentClaimIds, claimId},
      pendingRewardedRentClaim: RewardedRentClaim(
        id: claimId,
        bonusCoins: wholeCoins,
        localDayKey: localDayKey,
      ),
    );
    return TutorialSystem.afterRentCollection(collected);
  }

  static GameState grant(GameState state, String claimId) {
    final claim = state.pendingRewardedRentClaim;
    if (claim == null ||
        claim.id != claimId ||
        state.completedRewardedRentClaimIds.contains(claimId) ||
        _countForDay(state, claim.localDayKey) >=
            GameBalance.maximumRewardedRentBonusesPerDay) {
      return state;
    }
    return state.copyWith(
      walletCoins: state.walletCoins + claim.bonusCoins,
      pendingRewardedRentClaim: null,
      completedRewardedRentClaimIds: {
        ...state.completedRewardedRentClaimIds,
        claimId,
      },
      rewardedRentBonusDayKey: claim.localDayKey,
      rewardedRentBonusCount: _countForDay(state, claim.localDayKey) + 1,
    );
  }

  static GameState cancel(GameState state, String claimId) {
    if (state.pendingRewardedRentClaim?.id != claimId) return state;
    return state.copyWith(pendingRewardedRentClaim: null);
  }

  static int remainingForDay(GameState state, String localDayKey) =>
      GameBalance.maximumRewardedRentBonusesPerDay -
      _countForDay(state, localDayKey);

  static int _countForDay(GameState state, String localDayKey) =>
      state.rewardedRentBonusDayKey == localDayKey
      ? state.rewardedRentBonusCount
      : 0;
}
