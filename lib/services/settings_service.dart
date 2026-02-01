import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static AppSettings? _cachedSettings;

  Future<AppSettings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);
      
      if (jsonString == null) {
        _cachedSettings = const AppSettings();
        return _cachedSettings!;
      }
      
      final json = jsonDecode(jsonString);
      _cachedSettings = AppSettings.fromJson(json);
      return _cachedSettings!;
    } catch (e) {
      _cachedSettings = const AppSettings();
      return _cachedSettings!;
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, jsonString);
      _cachedSettings = settings;
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      _cachedSettings = const AppSettings();
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  // 개별 설정 업데이트 메서드들
  Future<void> updateReadingMode(ReadingMode mode) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(readingMode: mode));
  }

  Future<void> updateBrightness(double brightness) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(brightness: brightness));
  }

  Future<void> updateAutoHideToolbar(bool autoHide) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(autoHideToolbar: autoHide));
  }

  Future<void> updatePageTransition(PageTransition transition) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(pageTransition: transition));
  }

  Future<void> updateKeepScreenOn(bool keepOn) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(keepScreenOn: keepOn));
  }

  Future<void> updateShowPageNumbers(bool show) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(showPageNumbers: show));
  }

  Future<void> updateShowReadingProgress(bool show) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(showReadingProgress: show));
  }

  Future<void> updateZoomSensitivity(double sensitivity) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(zoomSensitivity: sensitivity));
  }

  Future<void> updateDoubleTapZoom(bool enable) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(enableDoubleTapZoom: enable));
  }

  Future<void> updateVolumeKeyNavigation(bool enable) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(enableVolumeKeyNavigation: enable));
  }

  Future<void> updateShowThumbnails(bool show) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(showThumbnails: show));
  }

  Future<void> updateThumbnailSize(int size) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(thumbnailSize: size));
  }
}