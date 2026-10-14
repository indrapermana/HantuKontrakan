class RewardedRentClaim {
  const RewardedRentClaim({
    required this.id,
    required this.bonusCoins,
    required this.localDayKey,
  });

  final String id;
  final int bonusCoins;
  final String localDayKey;

  Map<String, Object?> toJson() => {
    'id': id,
    'bonusCoins': bonusCoins,
    'localDayKey': localDayKey,
  };

  factory RewardedRentClaim.fromJson(Map<String, Object?> json) =>
      RewardedRentClaim(
        id: json['id']! as String,
        bonusCoins: json['bonusCoins']! as int,
        localDayKey: json['localDayKey']! as String,
      );
}
