class PDFFileInfo {
  final String filePath;
  final String fileName;
  final DateTime lastOpened;
  final int? fileSize;

  PDFFileInfo({
    required this.filePath,
    required this.fileName,
    required this.lastOpened,
    this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileName': fileName,
      'lastOpened': lastOpened.millisecondsSinceEpoch,
      'fileSize': fileSize,
    };
  }

  factory PDFFileInfo.fromJson(Map<String, dynamic> json) {
    return PDFFileInfo(
      filePath: json['filePath'],
      fileName: json['fileName'],
      lastOpened: DateTime.fromMillisecondsSinceEpoch(json['lastOpened']),
      fileSize: json['fileSize'],
    );
  }
}