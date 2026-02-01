import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pdf_file_info.dart';

class RecentFilesService {
  static const String _recentFilesKey = 'recent_pdf_files';
  static const int _maxRecentFiles = 10;

  Future<List<PDFFileInfo>> getRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentFilesKey);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final files = jsonList
          .map((json) => PDFFileInfo.fromJson(json))
          .where((file) => File(file.filePath).existsSync()) // 존재하는 파일만 필터링
          .toList();
      
      // 최근 순으로 정렬
      files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
      
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<void> addRecentFile(String filePath, String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentFiles = await getRecentFiles();
      
      // 이미 존재하는 파일이면 제거
      recentFiles.removeWhere((file) => file.filePath == filePath);
      
      // 파일 크기 가져오기
      int? fileSize;
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          fileSize = file.lengthSync();
        }
      } catch (e) {
        // 파일 크기를 가져올 수 없으면 null로 설정
      }
      
      // 새 파일을 맨 앞에 추가
      recentFiles.insert(0, PDFFileInfo(
        filePath: filePath,
        fileName: fileName,
        lastOpened: DateTime.now(),
        fileSize: fileSize,
      ));
      
      // 최대 개수 제한
      if (recentFiles.length > _maxRecentFiles) {
        recentFiles.removeRange(_maxRecentFiles, recentFiles.length);
      }
      
      // 저장
      final jsonList = recentFiles.map((file) => file.toJson()).toList();
      await prefs.setString(_recentFilesKey, json.encode(jsonList));
    } catch (e) {
      // 에러 발생 시 무시 (최근 파일 기능은 필수가 아님)
    }
  }

  Future<void> removeRecentFile(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentFiles = await getRecentFiles();
      
      recentFiles.removeWhere((file) => file.filePath == filePath);
      
      final jsonList = recentFiles.map((file) => file.toJson()).toList();
      await prefs.setString(_recentFilesKey, json.encode(jsonList));
    } catch (e) {
      // 에러 발생 시 무시
    }
  }

  Future<void> clearRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentFilesKey);
    } catch (e) {
      // 에러 발생 시 무시
    }
  }
}