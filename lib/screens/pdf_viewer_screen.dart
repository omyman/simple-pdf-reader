import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProgress();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.web, size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        '웹 PDF 리더',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '이 앱은 웹 버전으로 제작되었습니다.\n'
                        'PDF 파일을 관리하고 북마크를 추가할 수 있습니다.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (kIsWeb) ...[
                        const Text(
                          '웹 브라우저에서 실행 중입니다.',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showWebInstructions,
                          icon: const Icon(Icons.help_outline),
                          label: const Text('사용 방법'),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _addBookmark,
                          icon: const Icon(Icons.bookmark_add),
                          label: const Text('북마크 추가'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildFeatureList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주요 기능',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.folder_open, 'PDF 파일 관리'),
            _buildFeatureItem(Icons.bookmark, '북마크 시스템'),
            _buildFeatureItem(Icons.history, '읽기 진행률 추적'),
            _buildFeatureItem(Icons.library_books, '라이브러리 관리'),
            _buildFeatureItem(Icons.analytics, '읽기 통계'),
            _buildFeatureItem(Icons.settings, '개인화 설정'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _showWebInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('웹 앱 사용 방법'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📱 스마트폰에서 사용하기:'),
              SizedBox(height: 8),
              Text('1. 브라우저 메뉴 → "홈 화면에 추가"'),
              Text('2. 홈 화면 아이콘으로 앱처럼 사용'),
              SizedBox(height: 16),
              Text('💾 파일 관리:'),
              SizedBox(height: 8),
              Text('1. "PDF 열기" 버튼으로 파일 선택'),
              Text('2. 북마크 및 진행률 자동 저장'),
              Text('3. 라이브러리에서 파일 관리'),
              SizedBox(height: 16),
              Text('🔖 북마크:'),
              SizedBox(height: 8),
              Text('1. 중요한 파일 북마크 추가'),
              Text('2. 북마크 탭에서 빠른 접근'),
              Text('3. 메모 추가 가능'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
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