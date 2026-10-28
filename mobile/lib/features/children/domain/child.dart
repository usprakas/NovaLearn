/// Ordered PRE_K..GRADE_6 — display labels follow the same order for any grade picker UI.
const List<String> gradeLevels = <String>[
  'PRE_K', 'KINDERGARTEN', 'GRADE_1', 'GRADE_2', 'GRADE_3', 'GRADE_4', 'GRADE_5', 'GRADE_6',
];

String gradeLevelLabel(String gradeLevel) => switch (gradeLevel) {
      'PRE_K' => 'Pre-K',
      'KINDERGARTEN' => 'Kindergarten',
      _ => 'Grade ${gradeLevel.split('_').last}',
    };

class Child {
  const Child({
    required this.id,
    required this.displayName,
    required this.birthDate,
    required this.gradeLevel,
  });

  factory Child.fromJson(Map<String, Object?> json) => Child(
        id: json['id']! as String,
        displayName: json['displayName']! as String,
        birthDate: DateTime.parse(json['birthDate']! as String),
        gradeLevel: json['gradeLevel']! as String,
      );
  final String id;
  final String displayName;
  final DateTime birthDate;
  final String gradeLevel;
}

class ChildDraft {
  const ChildDraft({required this.displayName, required this.birthDate, required this.gradeLevel});
  final String displayName;
  final DateTime birthDate;
  final String gradeLevel;

  Map<String, String> toJson() => <String, String>{
        'displayName': displayName.trim(),
        'birthDate': birthDate.toIso8601String().substring(0, 10),
        'gradeLevel': gradeLevel,
      };
}
