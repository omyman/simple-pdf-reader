import 'package:flutter/material.dart';
import '../services/reading_progress_service.dart';
import '../services/bookmark_service.dart';
import '../services/recent_files_service.dart';
import '../models/reading_progress.dart';

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
  int _totalPagesRead = 0;
  double _averageProgress = 0.0;
  List<ReadingProgress> _recentActivity = [];

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
        _progressService.getAllProgress(),
      ]);

      final recentFiles = futures[0] as List;
      final completedBooks = futures[1] as List<ReadingProgress>;
      final inProgressBooks = futures[2] as List<ReadingProgress>;
      final bookmarks = futures[3] as List;
      final allProgress = futures[4] as List<ReadingProgress>;

      // 통계 계산
      _totalBooks = recentFiles.length;
      _completedBooks = completedBooks.length;
      _inProgressBooks = inProgressBooks.length;
      _totalBookmarks = bookmarks.length;
      
      // 총 읽은 페이지 수 계산
      _totalPagesRead = allProgress.fold(0, (sum, progress) => 
          sum + progress.currentPage);
      
      // 평균 진행률 계산
      if (allProgress.isNotEmpty) {
        _averageProgress = allProgress.fold(0.0, (sum, progress) => 
            sum + progress.progressPercentage) / allProgress.length;
      }

      // 최근 활동 (최근 5개)
      _recentActivity = allProgress
          .toList()
        ..sort((a, b) => b.lastRead.compareTo(a.lastRead))
        ..take(5).toList();

      setState(() {
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
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildReadingProgress(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '읽기 통계',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
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

  Widget _buildReadingProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '읽기 진행률',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '평균 진행률',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _averageProgress / 100,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_averageProgress.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Text(
                      _totalPagesRead.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      '총 읽은 페이지',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '최근 활동',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_recentActivity.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '최근 활동이 없습니다',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...._recentActivity.map((activity) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.menu_book,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                activity.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${activity.currentPage}/${activity.totalPages} 페이지 (${activity.progressPercentage.toStringAsFixed(0)}%)',
              ),
              trailing: Text(
                      _formatDate(activity.lastRead),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            ),
          )).toList(),
      ],
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
      {
        'title': '페이지 터너',
        'icon': Icons.pages,
        'achieved': _totalPagesRead >= 100,
      },
      {
        'title': '꾸준한 독자',
        'icon': Icons.trending_up,
        'achieved': _inProgressBooks >= 3,
      },
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}