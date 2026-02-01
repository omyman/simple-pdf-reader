import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'dart:async';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';
import '../models/app_settings.dart';
import '../services/bookmark_service.dart';
import '../services/reading_progress_service.dart';
import '../services/settings_service.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

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
  late PdfViewerController _pdfViewerController;
  final BookmarkService _bookmarkService = BookmarkService();
  final ReadingProgressService _progressService = ReadingProgressService();
  final SettingsService _settingsService = SettingsService();
  
  int _currentPageNumber = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isToolbarVisible = true;
  bool _isBookmarked = false;
  Timer? _hideToolbarTimer;
  Timer? _readingTimer;
  DateTime? _sessionStartTime;
  
  AppSettings _settings = const AppSettings();
  List<Bookmark> _bookmarks = [];
  ReadingProgress? _progress;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadSettings();
    _loadBookmarks();
    _loadProgress();
    _startReadingSession();
  }

  @override
  void dispose() {
    _hideToolbarTimer?.cancel();
    _readingTimer?.cancel();
    _saveReadingSession();
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.getSettings();
    setState(() {
      _settings = settings;
    });
    
    if (_settings.keepScreenOn) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _bookmarkService.getBookmarksForFile(widget.filePath);
    setState(() {
      _bookmarks = bookmarks;
    });
    _checkCurrentPageBookmark();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressService.getProgress(widget.filePath);
    setState(() {
      _progress = progress;
    });
    
    // 이전 읽던 페이지로 이동
    if (progress != null && progress.currentPage > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pdfViewerController.jumpToPage(progress.currentPage);
      });
    }
  }

  void _startReadingSession() {
    _sessionStartTime = DateTime.now();
    _readingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateReadingProgress();
    });
  }

  void _saveReadingSession() {
    if (_sessionStartTime != null && _totalPages > 0) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!).inMinutes;
      final currentProgress = _progress?.readingTimeMinutes ?? 0;
      
      final newProgress = ReadingProgress(
        filePath: widget.filePath,
        fileName: widget.fileName,
        currentPage: _currentPageNumber,
        totalPages: _totalPages,
        lastRead: DateTime.now(),
        readingTimeMinutes: currentProgress + sessionDuration,
      );
      
      _progressService.updateProgress(newProgress);
    }
  }

  void _updateReadingProgress() {
    if (_totalPages > 0) {
      final sessionDuration = _sessionStartTime != null 
          ? DateTime.now().difference(_sessionStartTime!).inMinutes 
          : 0;
      final currentProgress = _progress?.readingTimeMinutes ?? 0;
      
      final newProgress = ReadingProgress(
        filePath: widget.filePath,
        fileName: widget.fileName,
        currentPage: _currentPageNumber,
        totalPages: _totalPages,
        lastRead: DateTime.now(),
        readingTimeMinutes: currentProgress + sessionDuration,
      );
      
      setState(() {
        _progress = newProgress;
      });
      
      _progressService.updateProgress(newProgress);
    }
  }

  void _checkCurrentPageBookmark() {
    final isBookmarked = _bookmarks.any((bookmark) => bookmark.pageNumber == _currentPageNumber);
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  void _toggleToolbar() {
    setState(() {
      _isToolbarVisible = !_isToolbarVisible;
    });
    
    if (_isToolbarVisible && _settings.autoHideToolbar) {
      _startHideToolbarTimer();
    }
  }

  void _startHideToolbarTimer() {
    _hideToolbarTimer?.cancel();
    _hideToolbarTimer = Timer(Duration(seconds: _settings.autoHideDelay), () {
      if (mounted) {
        setState(() {
          _isToolbarVisible = false;
        });
      }
    });
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      // 북마크 제거
      final bookmark = _bookmarks.firstWhere(
        (b) => b.pageNumber == _currentPageNumber,
      );
      await _bookmarkService.removeBookmark(bookmark.id);
    } else {
      // 북마크 추가
      final bookmark = Bookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: widget.filePath,
        fileName: widget.fileName,
        pageNumber: _currentPageNumber,
        title: '페이지 $_currentPageNumber',
        createdAt: DateTime.now(),
      );
      await _bookmarkService.addBookmark(bookmark);
    }
    
    await _loadBookmarks();
    
    // 스낵바 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? '북마크가 제거되었습니다' : '북마크가 추가되었습니다'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookmarksScreen(
          filePath: widget.filePath,
          fileName: widget.fileName,
          onBookmarkTap: (pageNumber) {
            _pdfViewerController.jumpToPage(pageNumber);
            Navigator.pop(context);
          },
        ),
      ),
    ).then((_) => _loadBookmarks());
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    ).then((_) => _loadSettings());
  }

  Widget _buildReadingModeOverlay() {
    switch (_settings.readingMode) {
      case ReadingMode.sepia:
        return Container(
          color: Colors.orange.withOpacity(0.1),
          child: const SizedBox.expand(),
        );
      case ReadingMode.night:
        return Container(
          color: Colors.black.withOpacity(0.3),
          child: const SizedBox.expand(),
        );
      case ReadingMode.highContrast:
        return Container(
          color: Colors.black.withOpacity(0.1),
          child: const SizedBox.expand(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgressIndicator() {
    if (!_settings.showReadingProgress || _progress == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: _progress!.progressPercentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_progress!.progressPercentage.toStringAsFixed(1)}% 완료',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PDF 뷰어
          GestureDetector(
            onTap: _toggleToolbar,
            child: _buildPDFViewer(),
          ),
          
          // 읽기 모드 오버레이
          if (_settings.readingMode != ReadingMode.normal)
            IgnorePointer(child: _buildReadingModeOverlay()),
          
          // 상단 앱바
          if (_isToolbarVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(),
            ),
          
          // 하단 툴바
          if (_isToolbarVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomToolbar(),
            ),
          
          // 진행률 표시
          if (_settings.showReadingProgress && _isToolbarVisible)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _buildProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildPDFViewer() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '파일을 열 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('PDF를 불러오는 중...'),
          ],
        ),
      );
    }

    return SfPdfViewer.file(
      File(widget.filePath),
      controller: _pdfViewerController,
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        setState(() {
          _totalPages = details.document.pages.count;
          _isLoading = false;
        });
        _updateReadingProgress();
      },
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        setState(() {
          _errorMessage = details.error;
          _isLoading = false;
        });
      },
      onPageChanged: (PdfPageChangedDetails details) {
        setState(() {
          _currentPageNumber = details.newPageNumber;
        });
        _checkCurrentPageBookmark();
        _updateReadingProgress();
        
        if (_settings.autoHideToolbar && _isToolbarVisible) {
          _startHideToolbarTimer();
        }
      },
      enableDoubleTapZooming: _settings.enableDoubleTapZoom,
      enableTextSelection: true,
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (_settings.showPageNumbers && !_isLoading && _errorMessage == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '$_currentPageNumber / $_totalPages',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? Colors.amber : Colors.white,
              ),
              onPressed: _toggleBookmark,
            ),
            IconButton(
              icon: const Icon(Icons.bookmarks, color: Colors.white),
              onPressed: _showBookmarks,
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _showSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, color: Colors.white),
                onPressed: _currentPageNumber > 1
                    ? () => _pdfViewerController.firstPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.navigate_before, color: Colors.white),
                onPressed: _currentPageNumber > 1
                    ? () => _pdfViewerController.previousPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                onPressed: () => _pdfViewerController.zoomLevel -= 0.25,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                onPressed: () => _pdfViewerController.zoomLevel += 0.25,
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next, color: Colors.white),
                onPressed: _currentPageNumber < _totalPages
                    ? () => _pdfViewerController.nextPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, color: Colors.white),
                onPressed: _currentPageNumber < _totalPages
                    ? () => _pdfViewerController.lastPage()
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}