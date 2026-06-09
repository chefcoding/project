import 'dart:async';
import 'dart:math';

import '../models/sensor_reading.dart';
import 'sensor_data_source.dart';

/// 실제 워치가 없는 동안 사용하는 가짜 데이터 소스.
///
/// 평소에는 안정적인 값을 내보내다가, 가끔 "감정 에피소드"가 시작되면
/// 심박수·손목 움직임·음성이 함께 서서히 올라갔다가 다시 가라앉는다.
/// → 앱이 안정 → 주의 → 경고 → 위험 단계로 전환되는 모습을 데모할 수 있다.
class SimulatedSensorDataSource implements SensorDataSource {
  final _controller = StreamController<SensorReading>.broadcast();
  final _random = Random();
  Timer? _timer;

  /// 데이터 발생 주기
  final Duration interval;

  /// 현재 "흥분도" (0.0 안정 ~ 1.0 폭발). 내부 상태값.
  double _arousal = 0.0;

  /// 에피소드 진행 방향 (+ 상승 / - 하강 / 0 안정)
  double _trend = 0.0;

  /// 에피소드가 끝난 뒤 다음 에피소드까지 남은 평온 틱 수
  int _calmTicks = 8;

  SimulatedSensorDataSource({this.interval = const Duration(seconds: 1)});

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    _advanceArousal();

    // 흥분도를 실제 센서 값 범위로 변환 (약간의 노이즈 포함).
    final noise = (_random.nextDouble() - 0.5) * 6;
    final heartRate = 82 + _arousal * 70 + noise; // 82 ~ 152 bpm
    final wristMovement = (_arousal * 95 + noise).clamp(0, 100).toDouble();
    final voiceLevel =
        (_arousal * 90 + (_random.nextDouble() - 0.5) * 10).clamp(0, 100).toDouble();

    _controller.add(SensorReading(
      heartRate: heartRate,
      wristMovement: wristMovement,
      voiceLevel: voiceLevel,
      timestamp: DateTime.now(),
    ));
  }

  /// 에피소드 생애주기: 평온 → (랜덤) 상승 → 정점 → 하강 → 평온 반복.
  void _advanceArousal() {
    if (_trend == 0.0) {
      // 평온 구간: 가끔 새 에피소드 시작
      if (_calmTicks > 0) {
        _calmTicks--;
      } else if (_random.nextDouble() < 0.35) {
        _trend = 0.12 + _random.nextDouble() * 0.08; // 상승 시작
      }
    } else if (_trend > 0) {
      _arousal += _trend;
      if (_arousal >= 0.9) {
        _arousal = 0.9;
        _trend = -(0.08 + _random.nextDouble() * 0.06); // 하강으로 전환
      }
    } else {
      _arousal += _trend;
      if (_arousal <= 0.0) {
        _arousal = 0.0;
        _trend = 0.0;
        _calmTicks = 6 + _random.nextInt(8); // 다음 에피소드까지 휴식
      }
    }

    _arousal = _arousal.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
