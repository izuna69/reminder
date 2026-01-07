import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:reminder/models/task.dart';

class WidgetService {
  // 위젯 데이터를 업데이트하는 정적 메서드
  static Future<void> updateWidgetData(List<Task> tasks) async {
    try {
      // 위젯에 표시할 할 일 제목 목록 (최대 10개)
      final taskTitles = tasks
          .where((task) => !task.isCompleted) // 완료되지 않은 항목만 필터링
          .map((task) => task.title)
          .take(10)
          .toList();

      // JSON 문자열로 변환
      final jsonString = jsonEncode(taskTitles);

      // HomeWidget을 통해 데이터 저장
      await HomeWidget.saveWidgetData<String>('tasks', jsonString);
      
      // 위젯 업데이트 요청
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider',
        androidName: 'HomeWidgetProvider',
      );
    } catch (e) {
      print('Error updating widget data: $e');
    }
  }
}
