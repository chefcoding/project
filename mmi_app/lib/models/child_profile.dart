import 'dart:convert';

/// 보호자가 온보딩에서 입력하는 아이의 개인정보.
///
/// AI가 맞춤 가이드를 만들 때 이 정보를 함께 참고한다.
/// (예: 아이가 좋아하는 진정 방법, 알려진 트리거 등)
class ChildProfile {
  /// 아이 이름(또는 별칭)
  final String name;

  /// 나이 (만)
  final int age;

  /// 성별 ('남자' / '여자' / '기타' 등 자유 입력 허용)
  final String gender;

  /// 진단/특성 메모 (예: "자폐 스펙트럼, 감각 과민")
  final String diagnosis;

  /// 보호자가 이미 알고 있는 트리거 (감정 변화를 유발하는 상황)
  final List<String> knownTriggers;

  /// 보호자가 이미 알고 있는, 효과 있었던 진정 방법
  final List<String> calmingMethods;

  /// 그 외 보호자가 남기고 싶은 메모
  final String notes;

  const ChildProfile({
    required this.name,
    required this.age,
    required this.gender,
    this.diagnosis = '',
    this.knownTriggers = const [],
    this.calmingMethods = const [],
    this.notes = '',
  });

  ChildProfile copyWith({
    String? name,
    int? age,
    String? gender,
    String? diagnosis,
    List<String>? knownTriggers,
    List<String>? calmingMethods,
    String? notes,
  }) {
    return ChildProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      diagnosis: diagnosis ?? this.diagnosis,
      knownTriggers: knownTriggers ?? this.knownTriggers,
      calmingMethods: calmingMethods ?? this.calmingMethods,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'age': age,
        'gender': gender,
        'diagnosis': diagnosis,
        'knownTriggers': knownTriggers,
        'calmingMethods': calmingMethods,
        'notes': notes,
      };

  factory ChildProfile.fromMap(Map<String, dynamic> map) => ChildProfile(
        name: map['name'] as String? ?? '',
        age: (map['age'] as num?)?.toInt() ?? 0,
        gender: map['gender'] as String? ?? '',
        diagnosis: map['diagnosis'] as String? ?? '',
        knownTriggers:
            (map['knownTriggers'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        calmingMethods: (map['calmingMethods'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        notes: map['notes'] as String? ?? '',
      );

  String toJson() => jsonEncode(toMap());

  factory ChildProfile.fromJson(String source) =>
      ChildProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
