class ChildRewards {
  const ChildRewards({
    required this.coins,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ChildRewards.fromJson(Map<String, Object?> json) => ChildRewards(
        coins: json['coins']! as int,
        currentStreak: json['currentStreak']! as int,
        longestStreak: json['longestStreak']! as int,
      );

  final int coins;
  final int currentStreak;
  final int longestStreak;
}
