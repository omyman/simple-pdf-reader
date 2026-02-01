class ReadingProgress {
  final String filePath;
  final String fileName;
  final int currentPage;
  final int totalPages;
  final DateTime lastRead;
  final int readingTimeMinutes;

  ReadingProgress({
    required this.filePath,
    required this.fileName,
    required this.currentPage,
    required this.totalPages,
    required this.lastRead,
    this.readingTimeMinutes = 0,
  });

  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages) * 100;
  }

  bool get isCompleted => currentPage >= totalPages;

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileName': fileName,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastRead': lastRead.millisecondsSinceEpoch,
      'readingTimeMinutes': readingTimeMinutes,
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      filePath: json['filePath'],
      fileName: json['fileName'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      lastRead: DateTime.fromMillisecondsSinceEpoch(json['lastRead']),
      readingTimeMinutes: json['readingTimeMinutes'] ?? 0,
    );
  }

  ReadingProgress copyWith({
    String? filePath,
    String? fileName,
    int? currentPage,
    int? totalPages,
    DateTime? lastRead,
    int? readingTimeMinutes,
  }) {
    return ReadingProgress(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastRead: lastRead ?? this.lastRead,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
    );
  }
}