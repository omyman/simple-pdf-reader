import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class BookmarkService {
  static const String _bookmarksKey = 'pdf_bookmarks';

  Future<List<Bookmark>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_bookmarksKey);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Bookmark>> getBookmarksForFile(String filePath) async {
    final allBookmarks = await getBookmarks();
    return allBookmarks.where((bookmark) => bookmark.filePath == filePath).toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      final bookmarks = await getBookmarks();
      
      // 중복 체크 (같은 파일의 같은 페이지)
      final existingIndex = bookmarks.indexWhere(
        (b) => b.filePath == bookmark.filePath && b.pageNumber == bookmark.pageNumber,
      );
      
      if (existingIndex != -1) {
        // 기존 북마크 업데이트
        bookmarks[existingIndex] = bookmark;
      } else {
        // 새 북마크 추가
        bookmarks.add(bookmark);
      }
      
      await _saveBookmarks(bookmarks);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<void> removeBookmark(String bookmarkId) async {
    try {
      final bookmarks = await getBookmarks();
      bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
      await _saveBookmarks(bookmarks);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<void> removeBookmarksForFile(String filePath) async {
    try {
      final bookmarks = await getBookmarks();
      bookmarks.removeWhere((bookmark) => bookmark.filePath == filePath);
      await _saveBookmarks(bookmarks);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<bool> isBookmarked(String filePath, int pageNumber) async {
    final bookmarks = await getBookmarksForFile(filePath);
    return bookmarks.any((bookmark) => bookmark.pageNumber == pageNumber);
  }

  Future<void> _saveBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bookmarks.map((bookmark) => bookmark.toJson()).toList();
    await prefs.setString(_bookmarksKey, json.encode(jsonList));
  }

  Future<void> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }
}