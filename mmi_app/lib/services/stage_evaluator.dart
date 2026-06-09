import '../models/emotion_stage.dart';
import '../models/sensor_reading.dart';

/// 센서 값 한 묶음을 보고 감정 단계를 판정한다.
///
/// 작품설명서대로라면 이 임계값은 원래 "2주간 누적 데이터를 AI가 분석해
/// 아동별로 맞춤 설정"되는 부분이다. 프로토타입에서는 우선 고정 임계값을 쓰되,
/// 나중에 아동별 학습값으로 교체하기 쉽도록 한 곳에 모아둔다.
class StageThresholds {
  // 심박수 (bpm)
  final double hrCaution;
  final double hrWarning;
  final double hrDanger;

  // 손목 움직임 (0~100)
  final double moveCaution;
  final double moveWarning;
  final double moveDanger;

  // 음성 (0~100)
  final double voiceCaution;
  final double voiceWarning;
  final double voiceDanger;

  const StageThresholds({
    this.hrCaution = 105,
    this.hrWarning = 122,
    this.hrDanger = 138,
    this.moveCaution = 35,
    this.moveWarning = 60,
    this.moveDanger = 80,
    this.voiceCaution = 35,
    this.voiceWarning = 60,
    this.voiceDanger = 80,
  });
}

class StageEvaluator {
  final StageThresholds thresholds;

  const StageEvaluator({this.thresholds = const StageThresholds()});

  /// 세 지표 각각의 단계를 구한 뒤, 가장 심각한 단계를 전체 상태로 본다.
  /// (어느 한 신호라도 위험하면 위험으로 간주 — 안전 우선)
  EmotionStage evaluate(SensorReading r) {
    final stages = [
      _stageFor(r.heartRate, thresholds.hrCaution, thresholds.hrWarning,
          thresholds.hrDanger),
      _stageFor(r.wristMovement, thresholds.moveCaution, thresholds.moveWarning,
          thresholds.moveDanger),
      _stageFor(r.voiceLevel, thresholds.voiceCaution, thresholds.voiceWarning,
          thresholds.voiceDanger),
    ];
    return stages.reduce((a, b) => a.severity >= b.severity ? a : b);
  }

  EmotionStage _stageFor(
      double value, double caution, double warning, double danger) {
    if (value >= danger) return EmotionStage.danger;
    if (value >= warning) return EmotionStage.warning;
    if (value >= caution) return EmotionStage.caution;
    return EmotionStage.calm;
  }
}
