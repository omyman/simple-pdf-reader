import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/recent_files_service.dart';
import '../services/reading_progress_service.dart';
import '../services/bookmark_service.dart';
import '../models/pdf_file_info.dart';
import '../models/reading_progress.dart';
import '../models/bookmark.dart';
import 'pdf_viewer_screen.dart';
import 'library_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final RecentFilesService _recentFilesService = RecentFilesService();
  final ReadingProgressService _progressService = ReadingProgressService();
  final BookmarkService _bookmarkService = BookmarkService();
  
  late TabController _tabController;
  List<PDFFileInfo> _recentFiles = [];
  List<ReadingProgress> _inProgressBooks = [];
  List<ReadingProgress> _completedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final futures = await Future.wait([
      _recentFilesService.getRecentFiles(),
      _progressService.getInProgress(),
      _progressService.getCompleted(),
    ]);

    setState(() {
      _recentFiles = futures[0] as List<PDFFileInfo>;
      _inProgressBooks = futures[1] as List<ReadingProgress>;
      _completedBooks = futures[2] as List<ReadingProgress>;
      _isLoading = false;
    });
  }

  Future<void> _pickAndOpenPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        await _recentFilesService.addRecentFile(filePath, fileName);
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(
                filePath: filePath,
                fileName: fileName,
              ),
            ),
          ).then((_) => _loadData());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일을 열 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple PDF Reader'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: '홈'),
            Tab(icon: Icon(Icons.library_books), text: '라이브러리'),
            Tab(icon: Icon(Icons.bookmark), text: '북마크'),
            Tab(icon: Icon(Icons.analytics), text: '통계'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          LibraryScreen(onFileSelected: _openPDFFile),
          _buildBookmarksTab(),
          const StatisticsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndOpenPDF,
        icon: const Icon(Icons.add),
        label: const Text('PDF 열기'),
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 24),
            if (_inProgressBooks.isNotEmpty) ...[
              _buildSectionHeader('읽고 있는 책', Icons.menu_book),
              const SizedBox(height: 12),
              _buildInProgressBooks(),
              const SizedBox(height: 24),
            ],
            if (_recentFiles.isNotEmpty) ...[
              _buildSectionHeader('최근 파일', Icons.history),
              const SizedBox(height: 12),
              _buildRecentFiles(),
              const SizedBox(height: 24),
            ],
            if (_completedBooks.isNotEmpty) ...[
              _buildSectionHeader('완독한 책', Icons.check_circle),
              const SizedBox(height: 12),
              _buildCompletedBooks(),
            ],
            if (_recentFiles.isEmpty && _inProgressBooks.isEmpty && _completedBooks.isEmpty)
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 실행',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.folder_open,
                    label: 'PDF 열기',
                    onTap: _pickAndOpenPDF,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.library_books,
                    label: '라이브러리',
                    onTap: () => _tabController.animateTo(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.bookmark,
                    label: '북마크',
                    onTap: () => _tabController.animateTo(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.analytics,
                    label: '읽기 통계',
                    onTap: () => _tabController.animateTo(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressBooks() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _inProgressBooks.length,
        itemBuilder: (context, index) {
          final progress = _inProgressBooks[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: InkWell(
                onTap: () => _openPDFFile(progress.filePath, progress.fileName),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        progress.fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      LinearProgressIndicator(
                        value: progress.progressPercentage / 100,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.progressPercentage.toStringAsFixed(0)}% 완료',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${progress.currentPage}/${progress.totalPages} 페이지',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentFiles() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentFiles.take(5).length,
      itemBuilder: (context, index) {
        final file = _recentFiles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(
              file.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '마지막 열람: ${_formatDate(file.lastOpened)}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _recentFilesService.removeRecentFile(file.filePath);
                _loadData();
              },
            ),
            onTap: () => _openPDFFile(file.filePath, file.fileName),
          ),
        );
      },
    );
  }

  Widget _buildCompletedBooks() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _completedBooks.take(10).length,
        itemBuilder: (context, index) {
          final book = _completedBooks[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: InkWell(
                onTap: () => _openPDFFile(book.filePath, book.fileName),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.fileName,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Text(
                        '완독',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarksTab() {
    return FutureBuilder<List<Bookmark>>(
      future: _bookmarkService.getBookmarks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookmarks = snapshot.data ?? [];
        if (bookmarks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('북마크가 없습니다'),
                Text('PDF를 읽으면서 북마크를 추가해보세요'),
              ],
            ),
          );
        }

        // 파일별로 그룹화
        final groupedBookmarks = <String, List<Bookmark>>{};
        for (final bookmark in bookmarks) {
          groupedBookmarks.putIfAbsent(bookmark.fileName, () => []).add(bookmark);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedBookmarks.length,
          itemBuilder: (context, index) {
            final fileName = groupedBookmarks.keys.elementAt(index);
            final fileBookmarks = groupedBookmarks[fileName]!;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(fileName),
                subtitle: Text('${fileBookmarks.length}개의 북마크'),
                children: fileBookmarks.map((bookmark) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text(
                        bookmark.pageNumber.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(bookmark.title),
                    subtitle: bookmark.note != null 
                        ? Text(bookmark.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    onTap: () => _openPDFFile(bookmark.filePath, bookmark.fileName),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'PDF 파일을 열어보세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 눌러 PDF 파일을 선택하세요',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _openPDFFile(String filePath, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          filePath: filePath,
          fileName: fileName,
        ),
      ),
    ).then((_) => _loadData());
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '오늘 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }
}