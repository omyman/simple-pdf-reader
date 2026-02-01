import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    await _settingsService.updateSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReadingSection(),
          const SizedBox(height: 24),
          _buildDisplaySection(),
          const SizedBox(height: 24),
          _buildNavigationSection(),
          const SizedBox(height: 24),
          _buildAdvancedSection(),
        ],
      ),
    );
  }

  Widget _buildReadingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '읽기 설정',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // 읽기 모드
            ListTile(
              title: const Text('읽기 모드'),
              subtitle: Text(_getReadingModeText(_settings.readingMode)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showReadingModeDialog,
            ),
            
            // 밝기 조절
            ListTile(
              title: const Text('밝기'),
              subtitle: Slider(
                value: _settings.brightness,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${(_settings.brightness * 100).round()}%',
                onChanged: (value) {
                  _updateSettings(_settings.copyWith(brightness: value));
                },
              ),
            ),
            
            // 화면 켜짐 유지
            SwitchListTile(
              title: const Text('화면 켜짐 유지'),
              subtitle: const Text('읽는 동안 화면이 꺼지지 않습니다'),
              value: _settings.keepScreenOn,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(keepScreenOn: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '화면 표시',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // 페이지 번호 표시
            SwitchListTile(
              title: const Text('페이지 번호 표시'),
              subtitle: const Text('상단에 현재 페이지 번호를 표시합니다'),
              value: _settings.showPageNumbers,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(showPageNumbers: value));
              },
            ),
            
            // 읽기 진행률 표시
            SwitchListTile(
              title: const Text('읽기 진행률 표시'),
              subtitle: const Text('하단에 읽기 진행률을 표시합니다'),
              value: _settings.showReadingProgress,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(showReadingProgress: value));
              },
            ),
            
            // 툴바 자동 숨김
            SwitchListTile(
              title: const Text('툴바 자동 숨김'),
              subtitle: const Text('일정 시간 후 툴바를 자동으로 숨깁니다'),
              value: _settings.autoHideToolbar,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(autoHideToolbar: value));
              },
            ),
            
            // 자동 숨김 시간
            if (_settings.autoHideToolbar)
              ListTile(
                title: const Text('자동 숨김 시간'),
                subtitle: Text('${_settings.autoHideDelay}초'),
                trailing: SizedBox(
                  width: 100,
                  child: Slider(
                    value: _settings.autoHideDelay.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${_settings.autoHideDelay}초',
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(autoHideDelay: value.round()));
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '네비게이션',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // 더블탭 확대
            SwitchListTile(
              title: const Text('더블탭 확대'),
              subtitle: const Text('더블탭으로 확대/축소할 수 있습니다'),
              value: _settings.enableDoubleTapZoom,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(enableDoubleTapZoom: value));
              },
            ),
            
            // 확대/축소 민감도
            ListTile(
              title: const Text('확대/축소 민감도'),
              subtitle: Slider(
                value: _settings.zoomSensitivity,
                min: 0.5,
                max: 2.0,
                divisions: 6,
                label: '${_settings.zoomSensitivity.toStringAsFixed(1)}x',
                onChanged: (value) {
                  _updateSettings(_settings.copyWith(zoomSensitivity: value));
                },
              ),
            ),
            
            // 볼륨키 네비게이션
            SwitchListTile(
              title: const Text('볼륨키로 페이지 이동'),
              subtitle: const Text('볼륨 업/다운 키로 페이지를 이동합니다'),
              value: _settings.enableVolumeKeyNavigation,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(enableVolumeKeyNavigation: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '고급 설정',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // 썸네일 표시
            SwitchListTile(
              title: const Text('페이지 썸네일 표시'),
              subtitle: const Text('페이지 네비게이션에서 썸네일을 표시합니다'),
              value: _settings.showThumbnails,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(showThumbnails: value));
              },
            ),
            
            // 썸네일 크기
            if (_settings.showThumbnails)
              ListTile(
                title: const Text('썸네일 크기'),
                subtitle: Text(_getThumbnailSizeText(_settings.thumbnailSize)),
                trailing: SizedBox(
                  width: 100,
                  child: Slider(
                    value: _settings.thumbnailSize.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: _getThumbnailSizeText(_settings.thumbnailSize),
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(thumbnailSize: value.round()));
                    },
                  ),
                ),
              ),
            
            // 페이지 전환 효과
            ListTile(
              title: const Text('페이지 전환 효과'),
              subtitle: Text(_getPageTransitionText(_settings.pageTransition)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showPageTransitionDialog,
            ),
          ],
        ),
      ),
    );
  }

  String _getReadingModeText(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.normal:
        return '일반';
      case ReadingMode.sepia:
        return '세피아';
      case ReadingMode.night:
        return '야간 모드';
      case ReadingMode.highContrast:
        return '고대비';
    }
  }

  String _getThumbnailSizeText(int size) {
    switch (size) {
      case 1:
        return '작게';
      case 2:
        return '보통';
      case 3:
        return '크게';
      default:
        return '보통';
    }
  }

  String _getPageTransitionText(PageTransition transition) {
    switch (transition) {
      case PageTransition.slide:
        return '슬라이드';
      case PageTransition.fade:
        return '페이드';
      case PageTransition.curl:
        return '페이지 넘김';
      case PageTransition.none:
        return '없음';
    }
  }

  void _showReadingModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('읽기 모드 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReadingMode.values.map((mode) {
            return RadioListTile<ReadingMode>(
              title: Text(_getReadingModeText(mode)),
              value: mode,
              groupValue: _settings.readingMode,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(_settings.copyWith(readingMode: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPageTransitionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('페이지 전환 효과 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PageTransition.values.map((transition) {
            return RadioListTile<PageTransition>(
              title: Text(_getPageTransitionText(transition)),
              value: transition,
              groupValue: _settings.pageTransition,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(_settings.copyWith(pageTransition: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 기본값으로 되돌리시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.resetSettings();
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설정이 초기화되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}