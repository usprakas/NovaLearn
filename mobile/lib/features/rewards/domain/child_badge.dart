class ChildBadge {
  const ChildBadge({required this.badgeCode, required this.awardedAt});

  factory ChildBadge.fromJson(Map<String, Object?> json) => ChildBadge(
        badgeCode: json['badgeCode']! as String,
        awardedAt: DateTime.parse(json['awardedAt']! as String),
      );

  final String badgeCode;
  final DateTime awardedAt;
}
