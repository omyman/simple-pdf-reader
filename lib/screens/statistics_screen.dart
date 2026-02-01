import 'package:flutter/material.dart';
import '../services/reading_progress_service.dart';
import '../services/bookmark_service.dart';
import '../services/recent_files_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ReadingProgressService _progressService = ReadingProgressService();
  final BookmarkService _bookmarkService = BookmarkService();
  final RecentFilesService _recentFilesService = RecentFilesService();

  bool _isLoading = true;
  int _totalBooks = 0;
  int _completedBooks = 0;
  int _inProgressBooks = 0;
  int _totalBookmarks = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _recentFilesService.getRecentFiles(),
        _progressService.getCompleted(),
        _progressService.getInProgress(),
        _bookmarkService.getBookmarks(),
      ]);

      final recentFiles = futures[0] as List;
      final completedBooks = futures[1] as List;
      final inProgressBooks = futures[2] as List;
      final bookmarks = futures[3] as List;

      setState(() {
        _totalBooks = recentFiles.length;
        _completedBooks = completedBooks.length;
        _inProgressBooks = inProgressBooks.length;
        _totalBookmarks = bookmarks.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '읽기 통계',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          title: '전체 도서',
          value: _totalBooks.toString(),
          icon: Icons.library_books,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: '완독한 책',
          value: _completedBooks.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          title: '읽는 중',
          value: _inProgressBooks.toString(),
          icon: Icons.menu_book,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: '북마크',
          value: _totalBookmarks.toString(),
          icon: Icons.bookmark,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _getAchievements();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '성취',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Card(
              color: achievement['achieved'] 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      achievement['icon'],
                      color: achievement['achieved'] 
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['title'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: achievement['achieved'] 
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      {
        'title': '첫 번째 책',
        'icon': Icons.auto_stories,
        'achieved': _totalBooks >= 1,
      },
      {
        'title': '첫 완독',
        'icon': Icons.check_circle,
        'achieved': _completedBooks >= 1,
      },
      {
        'title': '북마크 수집가',
        'icon': Icons.bookmark,
        'achieved': _totalBookmarks >= 10,
      },
      {
        'title': '독서광',
        'icon': Icons.library_books,
        'achieved': _completedBooks >= 5,
      },
    ];
  }
}