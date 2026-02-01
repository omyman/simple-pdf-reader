import 'package:flutter/material.dart';
import 'package:pdfjs_viewer/pdfjs_viewer.dart';
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

  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressService.getProgress(widget.filePath);
    if (progress != null) {
      setState(() {
        _currentPage = progress.currentPage;
      });
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
      body: Column(
        children: [
          Expanded(
            child: PdfjsViewer.file(
              widget.filePath,
              viewerOptions: const PdfjsViewerOptions(
                initialPage: 1,
                enableTextSelection: true,
                enableAnnotations: false,
              ),
            ),
          ),
          _buildBottomControls(),
        ],
      ),
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
          Text(
            widget.fileName,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
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

  Future<void> _addBookmark() async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: widget.filePath,
      fileName: widget.fileName,
      pageNumber: _currentPage,
      title: '페이지 $_currentPage',
      createdAt: DateTime.now(),
    );

    await _bookmarkService.addBookmark(bookmark);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('북마크가 추가되었습니다')),
      );
    }
  }

  Future<void> _saveProgress() async {
    final progress = ReadingProgress(
      filePath: widget.filePath,
      fileName: widget.fileName,
      currentPage: _currentPage,
      totalPages: _totalPages,
      lastRead: DateTime.now(),
    );

    await _progressService.updateProgress(progress);
  }
}