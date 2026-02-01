import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/recent_files_service.dart';
import '../models/pdf_file_info.dart';

class LibraryScreen extends StatefulWidget {
  final Function(String filePath, String fileName) onFileSelected;

  const LibraryScreen({
    super.key,
    required this.onFileSelected,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final RecentFilesService _recentFilesService = RecentFilesService();
  List<PDFFileInfo> _allFiles = [];
  List<PDFFileInfo> _filteredFiles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name'; // name, date, size

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    final files = await _recentFilesService.getRecentFiles();
    setState(() {
      _allFiles = files;
      _filteredFiles = files;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredFiles = _allFiles.where((file) {
        return file.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      // 정렬 적용
      switch (_sortBy) {
        case 'name':
          _filteredFiles.sort((a, b) => a.fileName.compareTo(b.fileName));
          break;
        case 'date':
          _filteredFiles.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
          break;
        case 'size':
          _filteredFiles.sort((a, b) => (b.fileSize ?? 0).compareTo(a.fileSize ?? 0));
          break;
      }
    });
  }

  Future<void> _addNewFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        await _recentFilesService.addRecentFile(filePath, fileName);
        await _loadFiles();
        
        if (mounted) {
          widget.onFileSelected(filePath, fileName);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일을 추가할 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFileList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'PDF 파일 검색...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('정렬: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('이름순')),
                  DropdownMenuItem(value: 'date', child: Text('최근순')),
                  DropdownMenuItem(value: 'size', child: Text('크기순')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortBy = value;
                    });
                    _applyFilters();
                  }
                },
              ),
              const Spacer(),
              Text('총 ${_filteredFiles.length}개 파일'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    if (_filteredFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'PDF 파일이 없습니다' : '검색 결과가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty 
                  ? '+ 버튼을 눌러 PDF 파일을 추가하세요'
                  : '다른 검색어를 시도해보세요',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        final file = _filteredFiles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
            title: Text(
              file.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마지막 열람: ${_formatDate(file.lastOpened)}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                if (file.fileSize != null)
                  Text(
                    '크기: ${_formatFileSize(file.fileSize!)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'open':
                    widget.onFileSelected(file.filePath, file.fileName);
                    break;
                  case 'remove':
                    await _recentFilesService.removeRecentFile(file.filePath);
                    _loadFiles();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new),
                      SizedBox(width: 8),
                      Text('열기'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('제거', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => widget.onFileSelected(file.filePath, file.fileName),
          ),
        );
      },
    );
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}