import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder/models/task.dart';
import 'package:reminder/services/notification_service.dart';
import 'package:reminder/services/widget_service.dart';

// Task 리스트를 관리하는 StateNotifier
class TaskListNotifier extends StateNotifier<List<Task>> {
  // 초기 상태를 빈 리스트로 설정
  TaskListNotifier() : super([]);

  // 새로운 Task를 추가합니다.
  void addTask(Task task) {
    final newTask = task.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    state = [...state, newTask];
    _updateServices();

    if (!kIsWeb && !newTask.isCompleted) {
      NotificationService.instance.scheduleNotification(newTask);
    }
  }

  // Task를 업데이트합니다.
  void updateTask(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
    _updateServices();

    if (!kIsWeb) {
      if (!task.isCompleted) {
        NotificationService.instance.scheduleNotification(task);
      } else {
        NotificationService.instance.cancelNotification(task.id!);
      }
    }
  }

  // Task의 완료 상태를 토글합니다.
  void toggleComplete(Task task) {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    updateTask(updatedTask);
  }

  // Task를 삭제합니다.
  void deleteTask(int id) {
    state = state.where((t) => t.id != id).toList();
    _updateServices();

    if (!kIsWeb) {
      NotificationService.instance.cancelNotification(id);
    }
  }

  void _updateServices() {
    WidgetService.updateWidgetData(state);
  }

  // 체크리스트 항목의 완료 상태를 토글합니다.
  void toggleChecklistItem(int taskId, int itemIndex) {
    // ID로 해당 task를 찾습니다.
    final task = state.firstWhere((t) => t.id == taskId);

    // 체크리스트 항목들의 새 리스트를 만듭니다.
    final newDetails = List<ChecklistItem>.from(task.details);
    final item = newDetails[itemIndex];

    // 해당 인덱스의 항목을 상태가 변경된 새 항목으로 교체합니다.
    newDetails[itemIndex] = item.copyWith(isDone: !item.isDone);

    // 변경된 체크리스트를 포함하는 새 task 객체를 만듭니다.
    final updatedTask = task.copyWith(details: newDetails);

    // 전체 task를 업데이트합니다.
    updateTask(updatedTask);
  }
}

// TaskListNotifier를 사용하기 위한 Provider 정의
final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((
  ref,
) {
  return TaskListNotifier();
});
