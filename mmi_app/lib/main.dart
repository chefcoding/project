import 'package:flutter/material.dart';

import 'models/child_profile.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/guide_analysis_service.dart';
import 'services/local_store.dart';
import 'services/monitoring_controller.dart';
import 'services/simulated_sensor_data_source.dart';

void main() {
  runApp(const MmiApp());
}

class MmiApp extends StatelessWidget {
  const MmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMI 보호자 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4A78D6),
        useMaterial3: true,
      ),
      home: const _Bootstrap(),
    );
  }
}

/// 저장된 아이 프로필/맞춤 가이드를 불러온 뒤,
/// 프로필이 없으면 온보딩, 있으면 대시보드로 보낸다.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  final _store = LocalStore();
  MonitoringController? _controller;
  bool _needsOnboarding = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _store.loadProfile();
    final guides = await _store.loadGuides();
    final lastAnalysis = await _store.lastAnalysisAt();

    _controller = MonitoringController(
      // 데이터 소스 = 지금은 시뮬레이션.
      // 실제 워치가 생기면 이 한 줄만 BleSensorDataSource() 등으로 교체.
      source: SimulatedSensorDataSource(),
      // AI 분석기 = 지금은 온디바이스 mock.
      // 클라우드 연동 시 CloudClaudeGuideAnalysisService() 로 교체.
      analysisService: MockGuideAnalysisService(),
      store: _store,
      profile: profile,
      customGuides: guides,
      lastAnalysisAt: lastAnalysis,
    );

    setState(() {
      _needsOnboarding = profile == null;
      _loading = false;
    });
  }

  void _onOnboarded(ChildProfile profile) {
    _controller!.setProfile(profile);
    setState(() => _needsOnboarding = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_needsOnboarding) {
      return OnboardingScreen(onComplete: _onOnboarded);
    }
    return DashboardScreen(controller: _controller!);
  }
}
