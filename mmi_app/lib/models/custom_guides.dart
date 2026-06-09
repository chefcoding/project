import 'dart:convert';

import 'emotion_stage.dart';

/// AI가 2주 누적 데이터를 분석해 만들어낸, 이 아이만을 위한 맞춤 가이드 묶음.
///
/// 단계별로 기본 가이드를 "덮어쓰는" 역할을 한다.
/// (없으면 앱은 [EmotionStageInfo.actionGuide] 기본값을 사용)
class CustomGuideSet {
  /// 단계 → 맞춤 행동 가이드 문구
  final Map<EmotionStage, String> guides;

  /// AI가 파악한 이 아이의 감정 패턴 요약 (보호자에게 보여줄 한두 문장)
  final String patternSummary;

  /// 분석을 수행한 시각
  final DateTime generatedAt;

  const CustomGuideSet({
    required this.guides,
    required this.patternSummary,
    required this.generatedAt,
  });

  /// 해당 단계의 맞춤 가이드. 없으면 null.
  String? guideFor(EmotionStage stage) => guides[stage];

  Map<String, dynamic> toMap() => {
        'guides': guides.map((k, v) => MapEntry(k.name, v)),
        'patternSummary': patternSummary,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory CustomGuideSet.fromMap(Map<String, dynamic> map) {
    final rawGuides = (map['guides'] as Map?) ?? {};
    final parsed = <EmotionStage, String>{};
    for (final entry in rawGuides.entries) {
      final stage = EmotionStage.values
          .where((s) => s.name == entry.key)
          .cast<EmotionStage?>()
          .firstWhere((s) => s != null, orElse: () => null);
      if (stage != null) parsed[stage] = entry.value.toString();
    }
    return CustomGuideSet(
      guides: parsed,
      patternSummary: map['patternSummary'] as String? ?? '',
      generatedAt:
          DateTime.tryParse(map['generatedAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CustomGuideSet.fromJson(String source) =>
      CustomGuideSet.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
