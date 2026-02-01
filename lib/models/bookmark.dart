class Bookmark {
  final String id;
  final String filePath;
  final String fileName;
  final int pageNumber;
  final String title;
  final DateTime createdAt;
  final String? note;

  Bookmark({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.pageNumber,
    required this.title,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'pageNumber': pageNumber,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      filePath: json['filePath'],
      fileName: json['fileName'],
      pageNumber: json['pageNumber'],
      title: json['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      note: json['note'],
    );
  }

  Bookmark copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? pageNumber,
    String? title,
    DateTime? createdAt,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      pageNumber: pageNumber ?? this.pageNumber,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }
}