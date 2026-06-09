import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mmi_app/models/emotion_stage.dart';
import 'package:mmi_app/models/sensor_reading.dart';
import 'package:mmi_app/services/stage_evaluator.dart';

void main() {
  group('StageEvaluator', () {
    const evaluator = StageEvaluator();

    SensorReading reading(double hr, double move, double voice) => SensorReading(
          heartRate: hr,
          wristMovement: move,
          voiceLevel: voice,
          timestamp: DateTime(2026),
        );

    test('낮은 값이면 안정', () {
      expect(evaluator.evaluate(reading(85, 10, 10)), EmotionStage.calm);
    });

    test('어느 한 지표라도 위험이면 위험 (안전 우선)', () {
      expect(evaluator.evaluate(reading(85, 10, 90)), EmotionStage.danger);
    });

    test('중간 값이면 주의/경고 단계', () {
      expect(evaluator.evaluate(reading(110, 20, 20)), EmotionStage.caution);
      expect(evaluator.evaluate(reading(125, 20, 20)), EmotionStage.warning);
    });
  });

  testWidgets('단계 정보가 한국어 라벨을 가진다', (tester) async {
    expect(EmotionStage.danger.label, '위험');
    expect(EmotionStage.danger.needsAlert, isTrue);
    expect(EmotionStage.calm.needsAlert, isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
