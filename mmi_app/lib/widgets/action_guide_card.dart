import 'package:flutter/material.dart';

import '../models/emotion_stage.dart';

/// 현재 단계에서 보호자가 바로 할 수 있는 행동 가이드 카드.
class ActionGuideCard extends StatelessWidget {
  final EmotionStage stage;

  /// 표시할 가이드 문구. null이면 단계 기본 가이드를 사용.
  final String? guideText;

  /// AI 맞춤 가이드인지 (배지 표시용)
  final bool isPersonalized;

  const ActionGuideCard({
    super.key,
    required this.stage,
    this.guideText,
    this.isPersonalized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: stage.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stage.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: stage.color, size: 20),
              const SizedBox(width: 8),
              Text(
                '지금 해보세요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: stage.color,
                ),
              ),
              if (isPersonalized) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: stage.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI 맞춤',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: stage.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            guideText ?? stage.actionGuide,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
