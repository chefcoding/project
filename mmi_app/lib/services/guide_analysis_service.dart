import '../models/child_profile.dart';
import '../models/custom_guides.dart';
import '../models/emotion_stage.dart';
import 'monitoring_summary.dart';

/// "2주 누적 데이터 + 아이 프로필 → 맞춤 가이드"를 만들어내는 분석기의 규격.
///
/// 작품설명서 5번: 누적 데이터를 AI가 분석해 아동별 맞춤 진정 공략법을 만든다.
/// 이 분석은 본질적으로 서버(클라우드)에서 Claude로 처리하는 것이 맞으므로,
/// 인터페이스로 추상화해 두고 구현만 갈아끼운다.
///  - 지금: [MockGuideAnalysisService] (온디바이스 시뮬레이션)
///  - 나중: [CloudClaudeGuideAnalysisService] (클라우드 백엔드 → Claude)
abstract class GuideAnalysisService {
  Future<CustomGuideSet> analyze({
    required ChildProfile profile,
    required MonitoringSummary summary,
  });
}

/// 클라우드가 없는 동안 쓰는 가짜 분석기.
///
/// 프로필(아이가 좋아하는 진정 방법 등)과 누적 통계를 섞어,
/// "AI가 만든 것 같은" 개인 맞춤 가이드를 생성한다.
/// → 온보딩에서 입력한 정보가 가이드에 실제로 반영되는 흐름을 데모할 수 있다.
class MockGuideAnalysisService implements GuideAnalysisService {
  @override
  Future<CustomGuideSet> analyze({
    required ChildProfile profile,
    required MonitoringSummary summary,
  }) async {
    // 분석에 시간이 걸리는 것처럼 살짝 지연.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final name = profile.name.isEmpty ? '아이' : profile.name;
    final calming = profile.calmingMethods;
    final firstCalm = calming.isNotEmpty ? calming.first : '좋아하는 활동';
    final secondCalm = calming.length > 1 ? calming[1] : '안아주기';

    // 통계에서 "이 아이의 위험 임계"를 대략 추정해 문구에 녹인다.
    final peakHr = summary.peakHeartRate.toStringAsFixed(0);

    final guides = <EmotionStage, String>{
      EmotionStage.caution:
          '$name은(는) 이 시점에 "$firstCalm"이(가) 효과적이었어요. 먼저 권해보세요.',
      EmotionStage.warning:
          '심박이 $peakHr bpm 근처로 오를 때가 고비예요. "$secondCalm"(으)로 빠르게 안정시켜 주세요.',
      EmotionStage.danger:
          '$name에게는 안정 음악과 함께 "$firstCalm"을(를) 병행하는 것이 가장 빠른 진정 방법이에요.',
    };

    final summaryText = profile.knownTriggers.isNotEmpty
        ? '$name은(는) "${profile.knownTriggers.first}" 상황에서 감정 변화가 잦고, 심박이 평균 ${summary.avgHeartRate.toStringAsFixed(0)} bpm에서 최고 $peakHr bpm까지 올랐어요.'
        : '$name의 누적 데이터를 분석했어요. 심박이 평균 ${summary.avgHeartRate.toStringAsFixed(0)} bpm에서 최고 $peakHr bpm까지 올랐어요.';

    return CustomGuideSet(
      guides: guides,
      patternSummary: summaryText,
      generatedAt: DateTime.now(),
    );
  }
}

/// (추후 구현) 클라우드 백엔드를 거쳐 Claude로 분석하는 버전.
///
/// 보안상 API 키를 모바일 앱에 두면 안 되므로, 앱은 우리 백엔드에 요약 데이터를
/// 보내고, 백엔드가 Claude(`claude-opus-4-8`)를 호출해 맞춤 가이드를 받아 돌려준다.
/// 클라우드 작업 시 이 클래스를 구현해 [MockGuideAnalysisService] 자리에 끼우면 된다.
///
/// 참고 — 백엔드에서의 Claude 호출 형태(서버 측, 의사 코드):
/// ```
/// POST https://api.anthropic.com/v1/messages
/// {
///   "model": "claude-opus-4-8",
///   "max_tokens": 1024,
///   "messages": [{
///     "role": "user",
///     "content": "<아이 프로필 + 2주 요약 통계> 를 주고,
///                  단계별 맞춤 진정 가이드를 JSON으로 생성해줘"
///   }]
/// }
/// ```
class CloudClaudeGuideAnalysisService implements GuideAnalysisService {
  @override
  Future<CustomGuideSet> analyze({
    required ChildProfile profile,
    required MonitoringSummary summary,
  }) async {
    throw UnimplementedError(
        '클라우드 연동은 추후 구현 예정입니다. 지금은 MockGuideAnalysisService를 사용하세요.');
  }
}
