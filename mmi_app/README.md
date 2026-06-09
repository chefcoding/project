# MMI 보호자 앱 (프로토타입)

자폐 스펙트럼(ASD) 아동의 감정 변화를 **사전에** 감지해 보호자가 미리 대응할 수 있게 돕는 앱.
아이의 웨어러블 워치에서 **심박수 · 손목 움직임 · 음성 변화**를 받아 → **안정 / 주의 / 경고 / 위험** 단계로 표시하고, 단계가 올라가면 행동 가이드 알림을 띄운다.

> 작품설명서(`../resource/_MMI 작품설명서_00.docx.md`) 기반. iOS · Android 동시 지원 (Flutter).

## 현재 범위

- ✅ **온보딩** — 첫 실행 시 아이 개인정보 입력(이름/나이/성별/진단/트리거/진정법/메모), 기기에 로컬 저장
- ✅ 실시간 대시보드 — 3개 지표 + 현재 감정 단계
- ✅ 단계별 알림 + 행동 가이드
  - 주의(1단계): "10초 거꾸로 세기"
  - 경고(2단계): "안아주기"
  - 위험(3단계): "안정 음악 재생"
- ✅ **AI 맞춤 분석** — 누적 데이터 + 프로필 → 아동별 맞춤 가이드 생성, 기본 가이드를 덮어씀 (지금은 온디바이스 mock)
- ✅ 데이터 수신부 / AI 분석부 인터페이스 추상화 (지금은 **시뮬레이션 + mock**)
- ⬜ (다음 단계) 실제 워치 BLE 연동, **클라우드 백엔드 + Claude 분석**, 히스토리 그래프, 안정음악 재생, 푸시 알림

## 데이터 소스 교체 방법 (핵심)

부모 앱의 가장 중요한 역할은 "아이 장비에서 데이터를 잘 받아오는 것"이다.
그래서 수신부는 [`SensorDataSource`](lib/services/sensor_data_source.dart) 인터페이스로 추상화되어 있다.

지금은 [`SimulatedSensorDataSource`](lib/services/simulated_sensor_data_source.dart)(가짜 데이터)를 쓴다.
실제 워치가 생기면 같은 인터페이스를 구현한 클래스를 만들고 [`main.dart`](lib/main.dart)에서 **한 줄만** 바꾸면 된다:

```dart
// 지금
_controller = MonitoringController(source: SimulatedSensorDataSource());

// 실제 워치 (예시 — 추후 구현)
_controller = MonitoringController(source: BleSensorDataSource());     // 블루투스
// 또는
_controller = MonitoringController(source: CloudSensorDataSource());   // 클라우드
```

화면·단계판정·알림 코드는 전혀 손대지 않아도 된다.

## AI 맞춤 분석 (2주 주기) — 핵심

작품설명서대로 누적 데이터를 AI가 분석해 아동별 맞춤 가이드를 만든다. 이 분석은 본질적으로
**서버(클라우드)에서 Claude로 처리**하는 것이 맞으므로, [`GuideAnalysisService`](lib/services/guide_analysis_service.dart)
인터페이스로 추상화되어 있다.

- 지금: `MockGuideAnalysisService` — 프로필(좋아하는 진정 방법 등) + 누적 통계를 섞어 맞춤 가이드를 온디바이스에서 시뮬레이션
- 나중(클라우드): `CloudClaudeGuideAnalysisService` — 앱이 요약 데이터를 백엔드로 보내고, 백엔드가 Claude(`claude-opus-4-8`)를 호출해 맞춤 가이드를 받아 돌려줌 (API 키는 앱에 두지 않음)

생성된 맞춤 가이드는 단계별 기본 가이드를 덮어쓴다 → [`MonitoringController.guideFor()`](lib/services/monitoring_controller.dart).
2주 경과 시 "분석 권장" 배지가 뜨고, 데모에서는 "다시 분석하기" 버튼으로 즉시 실행할 수 있다.

## 구조

```
lib/
├─ main.dart                         앱 진입점: 저장된 프로필 로드 → 온보딩 or 대시보드
├─ models/
│  ├─ sensor_reading.dart            측정값 한 묶음 (심박/움직임/음성)
│  ├─ emotion_stage.dart             감정 단계 + 라벨/색상/기본 행동가이드
│  ├─ child_profile.dart             아이 개인정보 (온보딩 입력)
│  └─ custom_guides.dart             AI 맞춤 가이드 묶음
├─ services/
│  ├─ sensor_data_source.dart        데이터 수신 공통 인터페이스 ★
│  ├─ simulated_sensor_data_source.dart  시뮬레이션 구현
│  ├─ stage_evaluator.dart           측정값 → 단계 판정 (임계값)
│  ├─ monitoring_summary.dart        누적 데이터 요약 통계 (AI 입력)
│  ├─ guide_analysis_service.dart    AI 분석 인터페이스 + mock + 클라우드 stub ★
│  ├─ local_store.dart               프로필/가이드 로컬 저장 (나중에 클라우드로 교체)
│  └─ monitoring_controller.dart     두뇌: 수신→판정→알림→AI분석
├─ screens/
│  ├─ onboarding_screen.dart         아이 개인정보 입력
│  └─ dashboard_screen.dart          메인 대시보드 + AI 분석 카드
└─ widgets/                          상태배너 / 지표타일 / 가이드카드
```

## 실행

```bash
flutter pub get
flutter run            # 연결된 기기/시뮬레이터 선택
flutter test           # 단계 판정 로직 테스트
```
