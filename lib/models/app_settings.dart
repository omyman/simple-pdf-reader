enum ReadingMode {
  normal,
  sepia,
  night,
  highContrast,
}

enum PageTransition {
  slide,
  fade,
  curl,
  none,
}

class AppSettings {
  final ReadingMode readingMode;
  final double brightness;
  final bool autoHideToolbar;
  final int autoHideDelay; // seconds
  final PageTransition pageTransition;
  final bool enablePageTurnSound;
  final bool keepScreenOn;
  final bool showPageNumbers;
  final bool showReadingProgress;
  final double zoomSensitivity;
  final bool enableDoubleTapZoom;
  final bool enableVolumeKeyNavigation;
  final bool showThumbnails;
  final int thumbnailSize; // 1=small, 2=medium, 3=large

  const AppSettings({
    this.readingMode = ReadingMode.normal,
    this.brightness = 1.0,
    this.autoHideToolbar = true,
    this.autoHideDelay = 3,
    this.pageTransition = PageTransition.slide,
    this.enablePageTurnSound = false,
    this.keepScreenOn = false,
    this.showPageNumbers = true,
    this.showReadingProgress = true,
    this.zoomSensitivity = 1.0,
    this.enableDoubleTapZoom = true,
    this.enableVolumeKeyNavigation = false,
    this.showThumbnails = true,
    this.thumbnailSize = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      'readingMode': readingMode.index,
      'brightness': brightness,
      'autoHideToolbar': autoHideToolbar,
      'autoHideDelay': autoHideDelay,
      'pageTransition': pageTransition.index,
      'enablePageTurnSound': enablePageTurnSound,
      'keepScreenOn': keepScreenOn,
      'showPageNumbers': showPageNumbers,
      'showReadingProgress': showReadingProgress,
      'zoomSensitivity': zoomSensitivity,
      'enableDoubleTapZoom': enableDoubleTapZoom,
      'enableVolumeKeyNavigation': enableVolumeKeyNavigation,
      'showThumbnails': showThumbnails,
      'thumbnailSize': thumbnailSize,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      readingMode: ReadingMode.values[json['readingMode'] ?? 0],
      brightness: json['brightness']?.toDouble() ?? 1.0,
      autoHideToolbar: json['autoHideToolbar'] ?? true,
      autoHideDelay: json['autoHideDelay'] ?? 3,
      pageTransition: PageTransition.values[json['pageTransition'] ?? 0],
      enablePageTurnSound: json['enablePageTurnSound'] ?? false,
      keepScreenOn: json['keepScreenOn'] ?? false,
      showPageNumbers: json['showPageNumbers'] ?? true,
      showReadingProgress: json['showReadingProgress'] ?? true,
      zoomSensitivity: json['zoomSensitivity']?.toDouble() ?? 1.0,
      enableDoubleTapZoom: json['enableDoubleTapZoom'] ?? true,
      enableVolumeKeyNavigation: json['enableVolumeKeyNavigation'] ?? false,
      showThumbnails: json['showThumbnails'] ?? true,
      thumbnailSize: json['thumbnailSize'] ?? 2,
    );
  }

  AppSettings copyWith({
    ReadingMode? readingMode,
    double? brightness,
    bool? autoHideToolbar,
    int? autoHideDelay,
    PageTransition? pageTransition,
    bool? enablePageTurnSound,
    bool? keepScreenOn,
    bool? showPageNumbers,
    bool? showReadingProgress,
    double? zoomSensitivity,
    bool? enableDoubleTapZoom,
    bool? enableVolumeKeyNavigation,
    bool? showThumbnails,
    int? thumbnailSize,
  }) {
    return AppSettings(
      readingMode: readingMode ?? this.readingMode,
      brightness: brightness ?? this.brightness,
      autoHideToolbar: autoHideToolbar ?? this.autoHideToolbar,
      autoHideDelay: autoHideDelay ?? this.autoHideDelay,
      pageTransition: pageTransition ?? this.pageTransition,
      enablePageTurnSound: enablePageTurnSound ?? this.enablePageTurnSound,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      showReadingProgress: showReadingProgress ?? this.showReadingProgress,
      zoomSensitivity: zoomSensitivity ?? this.zoomSensitivity,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      enableVolumeKeyNavigation: enableVolumeKeyNavigation ?? this.enableVolumeKeyNavigation,
      showThumbnails: showThumbnails ?? this.showThumbnails,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    );
  }
}