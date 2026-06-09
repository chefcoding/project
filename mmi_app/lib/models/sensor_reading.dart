/// 아이의 웨어러블 워치에서 한 시점에 측정된 센서 값 한 묶음.
///
/// 실제 워치든 시뮬레이션이든, 데이터 소스는 이 형태로 값을 내보낸다.
/// (작품설명서: 심박수 / 손목 움직임 / 음성 변화 3가지를 실시간 측정)
class SensorReading {
  /// 심박수 (bpm)
  final double heartRate;

  /// 손목 움직임 강도 (0~100, 클수록 격하게 움직임)
  final double wristMovement;

  /// 음성 크기/변화 (0~100, 클수록 큰 소리/흥분)
  final double voiceLevel;

  /// 측정 시각
  final DateTime timestamp;

  const SensorReading({
    required this.heartRate,
    required this.wristMovement,
    required this.voiceLevel,
    required this.timestamp,
  });
}
