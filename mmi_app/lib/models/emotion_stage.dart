import 'package:flutter/material.dart';

/// 아이의 감정 상태 단계.
///
/// 작품설명서의 단계별 대응 시나리오를 그대로 반영한다.
///  - 안정: 평온한 상태
///  - 주의(1단계): 변화 시작 → "10초 거꾸로 세기"
///  - 경고(2단계): 흥분 고조 → "안아주기"
///  - 위험(3단계): 폭발 임박 → "안정 음악 재생"
enum EmotionStage {
  calm,
  caution,
  warning,
  danger,
}

extension EmotionStageInfo on EmotionStage {
  /// 화면에 표시할 한국어 이름
  String get label {
    switch (this) {
      case EmotionStage.calm:
        return '안정';
      case EmotionStage.caution:
        return '주의';
      case EmotionStage.warning:
        return '경고';
      case EmotionStage.danger:
        return '위험';
    }
  }

  /// 단계 표시용 색상
  Color get color {
    switch (this) {
      case EmotionStage.calm:
        return const Color(0xFF2E9E6B); // 초록
      case EmotionStage.caution:
        return const Color(0xFFE0A800); // 노랑
      case EmotionStage.warning:
        return const Color(0xFFE8730C); // 주황
      case EmotionStage.danger:
        return const Color(0xFFD93636); // 빨강
    }
  }

  /// 상태 한 줄 설명
  String get description {
    switch (this) {
      case EmotionStage.calm:
        return '아이가 안정적인 상태예요.';
      case EmotionStage.caution:
        return '감정 변화의 초기 신호가 감지됐어요.';
      case EmotionStage.warning:
        return '흥분이 고조되고 있어요. 가까이 가주세요.';
      case EmotionStage.danger:
        return '폭발 직전 신호예요. 즉시 진정이 필요해요.';
    }
  }

  /// 보호자에게 제시할 행동 가이드 (작품설명서 단계별 가이드)
  String get actionGuide {
    switch (this) {
      case EmotionStage.calm:
        return '특별한 조치는 필요 없어요. 평소처럼 함께해 주세요.';
      case EmotionStage.caution:
        return '아이와 함께 "10초 거꾸로 세기"를 해보세요.';
      case EmotionStage.warning:
        return '아이를 부드럽게 안아주세요. 조용한 공간으로 이동하는 것도 좋아요.';
      case EmotionStage.danger:
        return '안정 음악을 재생하고, 안전을 먼저 확보해 주세요.';
    }
  }

  /// 단계 아이콘
  IconData get icon {
    switch (this) {
      case EmotionStage.calm:
        return Icons.sentiment_satisfied_alt;
      case EmotionStage.caution:
        return Icons.info_outline;
      case EmotionStage.warning:
        return Icons.warning_amber_rounded;
      case EmotionStage.danger:
        return Icons.crisis_alert;
    }
  }

  /// 심각도 (단계 비교/정렬용). 클수록 위험.
  int get severity => index;

  /// 알림이 필요한 단계인가 (안정은 알림 없음)
  bool get needsAlert => this != EmotionStage.calm;
}
