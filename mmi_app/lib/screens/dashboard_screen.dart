import 'package:flutter/material.dart';

import '../models/emotion_stage.dart';
import '../models/sensor_reading.dart';
import '../services/monitoring_controller.dart';
import '../widgets/action_guide_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/status_banner.dart';
import 'onboarding_screen.dart';

/// 보호자용 메인 대시보드.
///
/// 아이 워치에서 들어오는 데이터를 실시간으로 보여주고,
/// 단계가 올라가면 행동 가이드 알림을 띄운다.
/// AI가 만든 맞춤 가이드가 있으면 기본 가이드 대신 그것을 사용한다.
class DashboardScreen extends StatefulWidget {
  final MonitoringController controller;

  const DashboardScreen({super.key, required this.controller});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    widget.controller.start();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
    final alert = widget.controller.pendingAlert;
    if (alert != null) {
      widget.controller.acknowledgeAlert();
      _showAlertSheet(alert);
    }
  }

  void _showAlertSheet(EmotionStage stage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertSheet(
        stage: stage,
        guideText: widget.controller.guideFor(stage),
        isPersonalized: widget.controller.hasCustomGuides,
      ),
    );
  }

  Future<void> _editProfile() async {
    final c = widget.controller;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OnboardingScreen(
        initial: c.profile,
        onComplete: (profile) {
          c.setProfile(profile);
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  Future<void> _runAnalysis() async {
    final c = widget.controller;
    await c.runAnalysis();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 맞춤 가이드가 업데이트됐어요.')),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final reading = c.latest;
    final stage = c.stage;
    final childName = c.profile?.name ?? '우리 아이';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('MMI · $childName 상태'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF222222),
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: '아이 정보 수정',
            icon: const Icon(Icons.person_outline),
            onPressed: _editProfile,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(Icons.watch,
                    size: 18,
                    color: c.isRunning
                        ? const Color(0xFF2E9E6B)
                        : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  c.isRunning ? '연결됨' : '끊김',
                  style: TextStyle(
                    fontSize: 13,
                    color: c.isRunning
                        ? const Color(0xFF2E9E6B)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBanner(stage: stage),
              const SizedBox(height: 16),
              ActionGuideCard(
                stage: stage,
                guideText: c.guideFor(stage),
                isPersonalized: c.hasCustomGuides,
              ),
              const SizedBox(height: 20),
              _aiAnalysisCard(c),
              const SizedBox(height: 20),
              const Text(
                '실시간 측정값',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _metrics(reading),
              const SizedBox(height: 20),
              if (reading != null)
                Text(
                  '마지막 업데이트  ${_formatTime(reading.timestamp)}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF999999)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// AI 맞춤 분석 카드 — 패턴 요약 + 재분석 버튼.
  Widget _aiAnalysisCard(MonitoringController c) {
    final summary = c.customGuides?.patternSummary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF7B5BD6), size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI 맞춤 분석',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (c.isAnalysisDue && !c.isAnalyzing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0A800).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('분석 권장',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB07F00))),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary ??
                '2주간 누적된 데이터를 분석하면 ${c.profile?.name ?? '아이'}에게 꼭 맞는 진정 가이드를 만들어 드려요.',
            style: const TextStyle(
                fontSize: 14, height: 1.4, color: Color(0xFF555555)),
          ),
          if (c.lastAnalysisAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '마지막 분석  ${_formatDate(c.lastAnalysisAt!)}',
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: c.isAnalyzing ? null : _runAnalysis,
              icon: c.isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(c.isAnalyzing
                  ? '분석 중...'
                  : (c.hasCustomGuides ? '다시 분석하기' : 'AI 맞춤 가이드 만들기')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metrics(SensorReading? r) {
    return Column(
      children: [
        MetricTile(
          icon: Icons.favorite,
          label: '심박수',
          value: r == null ? '--' : r.heartRate.toStringAsFixed(0),
          unit: 'bpm',
          progress: r == null ? 0 : (r.heartRate - 70) / 90,
          color: const Color(0xFFE0556B),
        ),
        const SizedBox(height: 12),
        MetricTile(
          icon: Icons.waving_hand,
          label: '손목 움직임',
          value: r == null ? '--' : r.wristMovement.toStringAsFixed(0),
          unit: '/100',
          progress: r == null ? 0 : r.wristMovement / 100,
          color: const Color(0xFF4A78D6),
        ),
        const SizedBox(height: 12),
        MetricTile(
          icon: Icons.graphic_eq,
          label: '음성 변화',
          value: r == null ? '--' : r.voiceLevel.toStringAsFixed(0),
          unit: '/100',
          progress: r == null ? 0 : r.voiceLevel / 100,
          color: const Color(0xFF7B5BD6),
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  String _formatDate(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}.${two(t.month)}.${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}

/// 단계 상승 시 올라오는 행동 가이드 알림 시트.
class _AlertSheet extends StatelessWidget {
  final EmotionStage stage;
  final String guideText;
  final bool isPersonalized;

  const _AlertSheet({
    required this.stage,
    required this.guideText,
    required this.isPersonalized,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 36,
            backgroundColor: stage.color.withValues(alpha: 0.15),
            child: Icon(stage.icon, color: stage.color, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            '${stage.label} 단계',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: stage.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stage.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: stage.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                if (isPersonalized) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: stage.color),
                      const SizedBox(width: 4),
                      Text('AI 맞춤 가이드',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: stage.color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  guideText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, height: 1.4, color: Color(0xFF222222)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: stage.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인했어요',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
