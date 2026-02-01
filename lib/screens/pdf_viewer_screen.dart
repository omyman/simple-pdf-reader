import 'package:flutter/material.dart';
import 'dart:io';
import '../services/bookmark_service.dart';
import '../services/reading_progress_service.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';

class PDFViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PDFViewerScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final ReadingProgressService _progressService = ReadingProgressService();
  
  bool _fileExists = false;
  String _fileSize = '';

  @override
  void initState() {
    super.initState();
    _checkFile();
    _loadProgress();
  }

  void _checkFile() {
    final file = File(widget.filePath);
    setState(() {
      _fileExists = file.existsSync();
      if (_fileExists) {
        final bytes = file.lengthSync();
        _fileSize = _formatFileSize(bytes);
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _loadProgress() async {
    final progress = await _progressService.getProgress(widget.filePath);
    if (progress != null) {
      // 진행률 로드됨
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: _addBookmark,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 120,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            Text(
              widget.fileName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_fileExists) ...[
              Text(
                '파일 크기: $_fileSize',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '파일 경로: ${widget.filePath}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'PDF 뷰어 기능',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '현재 버전에서는 PDF 파일 정보만 표시됩니다.\n'
                        '실제 PDF 내용을 보려면 기기의 기본 PDF 앱을 사용하세요.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openWithSystemApp,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('시스템 앱으로 열기'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text(
                '파일을 찾을 수 없습니다',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '북마크 및 진행률 관리',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _addBookmark,
            icon: const Icon(Icons.bookmark_add, size: 16),
            label: const Text('북마크'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _openWithSystemApp() {
    // 시스템 기본 앱으로 PDF 열기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('파일 관리자에서 PDF 파일을 찾아 기본 앱으로 여세요'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _addBookmark() async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: widget.filePath,
      fileName: widget.fileName,
      pageNumber: 1,
      title: widget.fileName,
      createdAt: DateTime.now(),
    );

    await _bookmarkService.addBookmark(bookmark);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('북마크가 추가되었습니다')),
      );
    }
  }
}