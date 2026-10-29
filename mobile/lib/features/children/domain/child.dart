/// Ordered PRE_K..GRADE_6 — display labels follow the same order for any grade picker UI.
const List<String> gradeLevels = <String>[
  'PRE_K', 'KINDERGARTEN', 'GRADE_1', 'GRADE_2', 'GRADE_3', 'GRADE_4', 'GRADE_5', 'GRADE_6',
];

String gradeLevelLabel(String gradeLevel) => switch (gradeLevel) {
      'PRE_K' => 'Pre-K',
      'KINDERGARTEN' => 'Kindergarten',
      _ => 'Grade ${gradeLevel.split('_').last}',
    };

/// The fixed set the backend accepts (`domain.child.Avatar`) — deliberately not a user-uploaded
/// photo, so a client always has exactly these five to choose from.
const List<String> avatars = <String>['FOX', 'OWL', 'ROBOT', 'ASTRONAUT', 'DRAGON'];

class Child {
  const Child({
    required this.id,
    required this.displayName,
    required this.birthDate,
    required this.gradeLevel,
    required this.avatar,
  });

  factory Child.fromJson(Map<String, Object?> json) => Child(
        id: json['id']! as String,
        displayName: json['displayName']! as String,
        birthDate: DateTime.parse(json['birthDate']! as String),
        gradeLevel: json['gradeLevel']! as String,
        avatar: json['avatar'] as String? ?? 'FOX',
      );
  final String id;
  final String displayName;
  final DateTime birthDate;
  final String gradeLevel;
  final String avatar;
}

class ChildDraft {
  const ChildDraft(
      {required this.displayName,
      required this.birthDate,
      required this.gradeLevel,
      required this.avatar});
  final String displayName;
  final DateTime birthDate;
  final String gradeLevel;
  final String avatar;

  Map<String, String> toJson() => <String, String>{
        'displayName': displayName.trim(),
        'birthDate': birthDate.toIso8601String().substring(0, 10),
        'gradeLevel': gradeLevel,
        'avatar': avatar,
      };
}
