import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/child_profile.dart';
import '../models/custom_guides.dart';
import '../models/emotion_stage.dart';
import '../models/sensor_reading.dart';
import 'guide_analysis_service.dart';
import 'local_store.dart';
import 'monitoring_summary.dart';
import 'sensor_data_source.dart';
import 'stage_evaluator.dart';

/// 앱의 두뇌.
///
/// 데이터 소스에서 측정값을 받아 → 단계를 판정하고 → 단계가 올라갈 때마다
/// 알림 신호를 띄운다. 또한 아이 프로필과 AI 맞춤 가이드를 관리하며,
/// 누적 데이터를 분석해 단계별 가이드를 갱신한다. 화면은 이 객체만 바라본다.
class MonitoringController extends ChangeNotifier {
  final SensorDataSource _source;
  final StageEvaluator _evaluator;
  final GuideAnalysisService _analysisService;
  final LocalStore _store;
  StreamSubscription<SensorReading>? _sub;

  /// AI 재분석 권장 주기 (작품설명서: 약 2주).
  static const Duration analysisInterval = Duration(days: 14);

  MonitoringController({
    required SensorDataSource source,
    required GuideAnalysisService analysisService,
    required LocalStore store,
    StageEvaluator evaluator = const StageEvaluator(),
    ChildProfile? profile,
    CustomGuideSet? customGuides,
    DateTime? lastAnalysisAt,
  })  : _source = source,
        _analysisService = analysisService,
        _store = store,
        _evaluator = evaluator,
        _profile = profile,
        _customGuides = customGuides,
        _lastAnalysisAt = lastAnalysisAt;

  SensorReading? _latest;
  EmotionStage _stage = EmotionStage.calm;
  bool _isRunning = false;
  EmotionStage? _pendingAlert;
  final List<SensorReading> _history = [];

  ChildProfile? _profile;
  CustomGuideSet? _customGuides;
  DateTime? _lastAnalysisAt;
  bool _isAnalyzing = false;

  SensorReading? get latest => _latest;
  EmotionStage get stage => _stage;
  bool get isRunning => _isRunning;
  EmotionStage? get pendingAlert => _pendingAlert;
  List<SensorReading> get history => List.unmodifiable(_history);

  ChildProfile? get profile => _profile;
  CustomGuideSet? get customGuides => _customGuides;
  DateTime? get lastAnalysisAt => _lastAnalysisAt;
  bool get isAnalyzing => _isAnalyzing;

  /// AI가 만든 맞춤 가이드가 적용 중인가
  bool get hasCustomGuides => _customGuides != null;

  /// 마지막 분석 이후 2주가 지나 재분석이 권장되는가
  /// (한 번도 분석 안 했고 데이터가 쌓였으면 true)
  bool get isAnalysisDue {
    if (_lastAnalysisAt == null) return _history.isNotEmpty;
    return DateTime.now().difference(_lastAnalysisAt!) >= analysisInterval;
  }

  /// 해당 단계에서 보호자에게 보여줄 행동 가이드.
  /// AI 맞춤 가이드가 있으면 그것을, 없으면 기본 가이드를 쓴다.
  String guideFor(EmotionStage stage) {
    return _customGuides?.guideFor(stage) ?? stage.actionGuide;
  }

  Future<void> start() async {
    if (_isRunning) return;
    _sub = _source.readings.listen(_onReading);
    await _source.start();
    _isRunning = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _source.stop();
    await _sub?.cancel();
    _sub = null;
    _isRunning = false;
    notifyListeners();
  }

  void _onReading(SensorReading reading) {
    _latest = reading;

    _history.add(reading);
    // 분석용으로 넉넉히 보관 (오래된 것부터 버림).
    if (_history.length > 1000) _history.removeAt(0);

    final newStage = _evaluator.evaluate(reading);
    if (newStage.severity > _stage.severity && newStage.needsAlert) {
      _pendingAlert = newStage;
    }
    _stage = newStage;

    notifyListeners();
  }

  void acknowledgeAlert() {
    _pendingAlert = null;
  }

  /// 아이 프로필 저장/갱신.
  Future<void> setProfile(ChildProfile profile) async {
    _profile = profile;
    await _store.saveProfile(profile);
    notifyListeners();
  }

  /// 누적 데이터를 AI에 보내 맞춤 가이드를 생성하고 적용한다.
  /// (작품설명서: 2주 주기. 데모에서는 버튼으로도 직접 실행 가능)
  Future<void> runAnalysis() async {
    if (_isAnalyzing || _profile == null) return;
    _isAnalyzing = true;
    notifyListeners();
    try {
      final summary =
          MonitoringSummary.fromReadings(_history, evaluator: _evaluator);
      final guides = await _analysisService.analyze(
        profile: _profile!,
        summary: summary,
      );
      _customGuides = guides;
      _lastAnalysisAt = guides.generatedAt;
      await _store.saveGuides(guides);
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _source.dispose();
    super.dispose();
  }
}
