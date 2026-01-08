import 'dart:convert';
import 'package:reminder/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'tasks';

  // Task 리스트를 SharedPreferences에 저장
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    // List<Task>를 List<Map<String, dynamic>>으로 변환
    final List<Map<String, dynamic>> tasksAsJson =
        tasks.map((task) => task.toJson()).toList();
    // JSON 문자열로 인코딩
    final String jsonString = jsonEncode(tasksAsJson);
    await prefs.setString(_storageKey, jsonString);
  }

  // SharedPreferences에서 Task 리스트를 불러오기
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return [];
    }

    // JSON 문자열을 List<dynamic>으로 디코딩
    final List<dynamic> tasksAsJson = jsonDecode(jsonString);
    // List<dynamic>을 List<Task>로 변환
    final List<Task> tasks =
        tasksAsJson.map((json) => Task.fromJson(json)).toList();
    return tasks;
  }
}
