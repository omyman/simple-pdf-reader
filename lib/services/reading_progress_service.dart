import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_progress.dart';

class ReadingProgressService {
  static const String _progressKey = 'reading_progress';

  Future<List<ReadingProgress>> getAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_progressKey);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ReadingProgress.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ReadingProgress?> getProgress(String filePath) async {
    final allProgress = await getAllProgress();
    try {
      return allProgress.firstWhere((progress) => progress.filePath == filePath);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProgress(ReadingProgress progress) async {
    try {
      final allProgress = await getAllProgress();
      
      final existingIndex = allProgress.indexWhere(
        (p) => p.filePath == progress.filePath,
      );
      
      if (existingIndex != -1) {
        allProgress[existingIndex] = progress;
      } else {
        allProgress.add(progress);
      }
      
      await _saveProgress(allProgress);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<void> removeProgress(String filePath) async {
    try {
      final allProgress = await getAllProgress();
      allProgress.removeWhere((progress) => progress.filePath == filePath);
      await _saveProgress(allProgress);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<void> _saveProgress(List<ReadingProgress> progressList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = progressList.map((progress) => progress.toJson()).toList();
    await prefs.setString(_progressKey, json.encode(jsonList));
  }

  Future<void> clearAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<List<ReadingProgress>> getRecentlyRead({int limit = 10}) async {
    final allProgress = await getAllProgress();
    allProgress.sort((a, b) => b.lastRead.compareTo(a.lastRead));
    return allProgress.take(limit).toList();
  }

  Future<List<ReadingProgress>> getInProgress() async {
    final allProgress = await getAllProgress();
    return allProgress.where((progress) => 
      progress.currentPage > 1 && !progress.isCompleted
    ).toList();
  }

  Future<List<ReadingProgress>> getCompleted() async {
    final allProgress = await getAllProgress();
    return allProgress.where((progress) => progress.isCompleted).toList();
  }
}