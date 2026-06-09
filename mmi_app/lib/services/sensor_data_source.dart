import '../models/sensor_reading.dart';

/// 아이 워치/장비에서 센서 데이터를 받아오는 "통로"의 공통 규격.
///
/// 부모 앱의 핵심 역할은 "데이터를 잘 받아오는 것"이므로,
/// 이 인터페이스만 지키면 데이터가 어디서 오는지(시뮬레이션 / 블루투스 / 클라우드)는
/// 화면 코드가 전혀 신경 쓸 필요가 없다.
///
/// 나중에 실제 워치가 생기면 이 인터페이스를 구현한
/// `BleSensorDataSource` 나 `CloudSensorDataSource` 를 만들어
/// 끼워넣기만 하면 된다. (화면 코드는 그대로)
abstract class SensorDataSource {
  /// 측정값이 들어올 때마다 흘러나오는 스트림.
  Stream<SensorReading> get readings;

  /// 데이터 수신 시작 (워치 연결 / 시뮬레이션 시작 등)
  Future<void> start();

  /// 데이터 수신 종료
  Future<void> stop();

  /// 정리 (스트림 닫기 등)
  void dispose();
}
