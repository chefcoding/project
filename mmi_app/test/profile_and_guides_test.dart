import 'package:flutter_test/flutter_test.dart';

import 'package:mmi_app/models/child_profile.dart';
import 'package:mmi_app/models/emotion_stage.dart';
import 'package:mmi_app/services/guide_analysis_service.dart';
import 'package:mmi_app/services/monitoring_summary.dart';

void main() {
  group('ChildProfile 직렬화', () {
    test('toJson → fromJson 왕복', () {
      const p = ChildProfile(
        name: '민준',
        age: 7,
        gender: '남자',
        diagnosis: '자폐 스펙트럼',
        knownTriggers: ['큰 소리', '일정 변화'],
        calmingMethods: ['좋아하는 노래', '안아주기'],
        notes: '메모',
      );
      final back = ChildProfile.fromJson(p.toJson());
      expect(back.name, '민준');
      expect(back.age, 7);
      expect(back.knownTriggers, ['큰 소리', '일정 변화']);
      expect(back.calmingMethods.length, 2);
    });
  });

  group('MockGuideAnalysisService', () {
    test('프로필의 진정 방법을 가이드 문구에 반영한다', () async {
      const profile = ChildProfile(
        name: '서연',
        age: 6,
        gender: '여자',
        calmingMethods: ['콩순이 노래'],
        knownTriggers: ['시끄러운 교실'],
      );
      const summary = MonitoringSummary(
        sampleCount: 100,
        avgHeartRate: 95,
        peakHeartRate: 140,
        peakWristMovement: 80,
        peakVoiceLevel: 75,
        stageCounts: {},
      );

      final guides = await MockGuideAnalysisService()
          .analyze(profile: profile, summary: summary);

      // 아이 이름과 진정 방법이 가이드에 들어가야 한다.
      expect(guides.guideFor(EmotionStage.caution), contains('서연'));
      expect(guides.guideFor(EmotionStage.caution), contains('콩순이 노래'));
      // 패턴 요약에 트리거가 반영된다.
      expect(guides.patternSummary, contains('시끄러운 교실'));
    });
  });

  group('MonitoringSummary', () {
    test('빈 데이터면 isEmpty', () {
      final s = MonitoringSummary.fromReadings(const []);
      expect(s.isEmpty, isTrue);
    });
  });
}
