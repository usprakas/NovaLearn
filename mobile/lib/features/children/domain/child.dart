class Child {
  const Child({
    required this.id,
    required this.displayName,
    required this.birthDate,
  });

  factory Child.fromJson(Map<String, Object?> json) => Child(
        id: json['id']! as String,
        displayName: json['displayName']! as String,
        birthDate: DateTime.parse(json['birthDate']! as String),
      );
  final String id;
  final String displayName;
  final DateTime birthDate;
}

class ChildDraft {
  const ChildDraft({required this.displayName, required this.birthDate});
  final String displayName;
  final DateTime birthDate;

  Map<String, String> toJson() => <String, String>{
        'displayName': displayName.trim(),
        'birthDate': birthDate.toIso8601String().substring(0, 10),
      };
}
