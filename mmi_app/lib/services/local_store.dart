import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_profile.dart';
import '../models/custom_guides.dart';

/// 아이 프로필과 맞춤 가이드를 기기에 로컬 저장/로드.
///
/// 지금은 기기 로컬(SharedPreferences)에 저장한다.
/// 나중에 클라우드를 붙이면 이 클래스의 구현만 클라우드 동기화로 바꾸면 된다.
class LocalStore {
  static const _kProfile = 'child_profile';
  static const _kGuides = 'custom_guides';
  static const _kLastAnalysis = 'last_analysis_at';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- 아이 프로필 ---
  Future<ChildProfile?> loadProfile() async {
    final raw = (await _prefs).getString(_kProfile);
    if (raw == null) return null;
    try {
      return ChildProfile.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(ChildProfile profile) async {
    await (await _prefs).setString(_kProfile, profile.toJson());
  }

  // --- 맞춤 가이드 ---
  Future<CustomGuideSet?> loadGuides() async {
    final raw = (await _prefs).getString(_kGuides);
    if (raw == null) return null;
    try {
      return CustomGuideSet.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveGuides(CustomGuideSet guides) async {
    await (await _prefs).setString(_kGuides, guides.toJson());
    await (await _prefs)
        .setString(_kLastAnalysis, guides.generatedAt.toIso8601String());
  }

  Future<DateTime?> lastAnalysisAt() async {
    final raw = (await _prefs).getString(_kLastAnalysis);
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
