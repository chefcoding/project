import 'package:flutter/material.dart';

import '../models/emotion_stage.dart';

/// 화면 맨 위, 현재 감정 단계를 크게 보여주는 배너.
class StatusBanner extends StatelessWidget {
  final EmotionStage stage;

  const StatusBanner({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [stage.color, stage.color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(stage.icon, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            stage.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stage.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
