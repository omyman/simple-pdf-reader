import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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

  PDFViewController? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isReady = false;
  bool _showAppBar = true;

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
      appBar: _showAppBar ? AppBar(
        title: Text(
          widget.fileName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _addBookmark,
          ),
        ],
      ) : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showAppBar = !_showAppBar;
          });
        },
        child: Stack(
          children: [
            PDFView(
              filePath: widget.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage - 1,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages ?? 0;
                  _isReady = true;
                });
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF 로드 오류: $error')),
                );
              },
              onPageError: (page, error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('페이지 $page 오류: $error')),
                );
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  setState(() {
                    _currentPage = page + 1;
                  });
                  _saveProgress();
                }
              },
            ),
            if (_isReady) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showAppBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: _currentPage > 1 ? _previousPage : null,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_currentPage / $_totalPages',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _totalPages > 0 ? _currentPage / _totalPages : 0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: _currentPage < _totalPages ? _nextPage : null,
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add, color: Colors.white),
                onPressed: _addBookmark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _pdfController?.setPage(_currentPage - 2);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _pdfController?.setPage(_currentPage);
    }
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