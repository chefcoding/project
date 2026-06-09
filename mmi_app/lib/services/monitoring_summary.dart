import '../models/emotion_stage.dart';
import '../models/sensor_reading.dart';
import 'stage_evaluator.dart';

/// 누적된 측정값을 AI에게 보내기 좋게 요약한 통계.
///
/// 작품설명서의 "2주간 누적 데이터"에 해당하는 입력을, 원시 데이터 대신
/// 압축된 통계로 만들어 AI(또는 클라우드)에 전달한다.
class MonitoringSummary {
  final int sampleCount;
  final double avgHeartRate;
  final double peakHeartRate;
  final double peakWristMovement;
  final double peakVoiceLevel;

  /// 단계별로 머문 횟수 (안정/주의/경고/위험 분포)
  final Map<EmotionStage, int> stageCounts;

  const MonitoringSummary({
    required this.sampleCount,
    required this.avgHeartRate,
    required this.peakHeartRate,
    required this.peakWristMovement,
    required this.peakVoiceLevel,
    required this.stageCounts,
  });

  bool get isEmpty => sampleCount == 0;

  /// 측정값 목록에서 요약 통계를 계산한다.
  factory MonitoringSummary.fromReadings(
    List<SensorReading> readings, {
    StageEvaluator evaluator = const StageEvaluator(),
  }) {
    if (readings.isEmpty) {
      return const MonitoringSummary(
        sampleCount: 0,
        avgHeartRate: 0,
        peakHeartRate: 0,
        peakWristMovement: 0,
        peakVoiceLevel: 0,
        stageCounts: {},
      );
    }

    double hrSum = 0, hrPeak = 0, movePeak = 0, voicePeak = 0;
    final counts = <EmotionStage, int>{};
    for (final r in readings) {
      hrSum += r.heartRate;
      if (r.heartRate > hrPeak) hrPeak = r.heartRate;
      if (r.wristMovement > movePeak) movePeak = r.wristMovement;
      if (r.voiceLevel > voicePeak) voicePeak = r.voiceLevel;
      final stage = evaluator.evaluate(r);
      counts[stage] = (counts[stage] ?? 0) + 1;
    }

    return MonitoringSummary(
      sampleCount: readings.length,
      avgHeartRate: hrSum / readings.length,
      peakHeartRate: hrPeak,
      peakWristMovement: movePeak,
      peakVoiceLevel: voicePeak,
      stageCounts: counts,
    );
  }
}
