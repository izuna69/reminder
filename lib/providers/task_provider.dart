import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder/models/task.dart';
import 'package:reminder/services/notification_service.dart';
import 'package:reminder/services/storage_service.dart';
import 'package:reminder/services/widget_service.dart';

// 모든 Task(삭제된 것 포함) 리스트를 관리하는 메인 Notifier
class TaskListNotifier extends AsyncNotifier<List<Task>> {
  Future<List<Task>> _getTasks() => StorageService.getTasks();
  Future<void> _setTasks(List<Task> tasks) => StorageService.saveTasks(tasks);

  @override
  Future<List<Task>> build() async {
    final tasks = await _getTasks();
    await WidgetService.updateWidgetData(
      tasks.where((t) => !t.isDeleted).toList(),
    );
    return tasks;
  }

  // 새로운 Task를 추가합니다.
  Future<void> addTask(Task task) async {
    final tasks = state.valueOrNull ?? [];
    final newTask = task.copyWith(id: DateTime.now().millisecondsSinceEpoch);
    final newTasks = [...tasks, newTask];

    await _setTasks(newTasks);
    state = AsyncValue.data(newTasks);
    _updateServices(newTask);
  }

  // Task를 업데이트합니다.
  Future<void> updateTask(Task task) async {
    final tasks = state.valueOrNull ?? [];
    final newTasks = [
      for (final t in tasks)
        if (t.id == task.id) task else t,
    ];
    await _setTasks(newTasks);
    state = AsyncValue.data(newTasks);
    _updateServices(task);
  }

  // 상세 항목의 순서를 변경하고 저장합니다.
  Future<void> reorderChecklistItem(
    int taskId,
    int oldIndex,
    int newIndex,
  ) async {
    final tasks = state.valueOrNull ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    // 상세 항목 리스트 복사 및 순서 재배치
    final newDetails = List<ChecklistItem>.from(task.details);
    final item = newDetails.removeAt(oldIndex);
    newDetails.insert(newIndex, item);

    // 변경된 리스트로 Task 업데이트
    final updatedTask = task.copyWith(details: newDetails);
    await updateTask(updatedTask);
  }

  // Task를 휴지통으로 보냅니다 (soft-delete).
  Future<void> deleteTask(int id) async {
    final tasks = state.valueOrNull ?? [];
    Task? taskToUpdate;
    final newTasks = tasks.map((t) {
      if (t.id == id) {
        taskToUpdate = t.copyWith(isDeleted: true);
        return taskToUpdate!;
      }
      return t;
    }).toList();

    await _setTasks(newTasks);
    state = AsyncValue.data(newTasks);
    if (taskToUpdate != null) {
      _updateServices(taskToUpdate!);
    }
  }

  // Task를 복원합니다.
  Future<void> restoreTask(int id) async {
    final tasks = state.valueOrNull ?? [];
    Task? taskToUpdate;
    final newTasks = tasks.map((t) {
      if (t.id == id) {
        taskToUpdate = t.copyWith(isDeleted: false);
        return taskToUpdate!;
      }
      return t;
    }).toList();

    await _setTasks(newTasks);
    state = AsyncValue.data(newTasks);
    if (taskToUpdate != null) {
      _updateServices(taskToUpdate!);
    }
  }

  // Task를 영구적으로 삭제합니다.
  Future<void> permanentlyDeleteTask(int id) async {
    final tasks = state.valueOrNull ?? [];
    final newTasks = tasks.where((t) => t.id != id).toList();
    await _setTasks(newTasks);
    state = AsyncValue.data(newTasks);

    if (!kIsWeb) {
      await NotificationService.instance.cancelNotification(id);
    }
    await WidgetService.updateWidgetData(
      newTasks.where((t) => !t.isDeleted).toList(),
    );
  }

  // 여러 Task를 영구적으로 삭제합니다.
  Future<void> permanentlyDeleteMultipleTasks(List<int> ids) async {
    final tasks = state.valueOrNull ?? [];
    final idSet = ids.toSet();
    final newTasks = tasks.where((t) => !idSet.contains(t.id)).toList();

    await _setTasks(newTasks);
    state = AsyncValue.data(newTasks);

    if (!kIsWeb) {
      for (final id in ids) {
        await NotificationService.instance.cancelNotification(id);
      }
    }
    await WidgetService.updateWidgetData(
      newTasks.where((t) => !t.isDeleted).toList(),
    );
  }

  // Task의 완료 상태를 토글합니다.
  Future<void> toggleComplete(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  // 체크리스트 항목의 완료 상태를 토글합니다.
  Future<void> toggleChecklistItem(int taskId, int itemIndex) async {
    final tasks = state.valueOrNull ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final newDetails = List<ChecklistItem>.from(task.details);
    final item = newDetails[itemIndex];
    newDetails[itemIndex] = item.copyWith(isDone: !item.isDone);

    final updatedTask = task.copyWith(details: newDetails);
    await updateTask(updatedTask);
  }

  // 서비스 업데이트 헬퍼
  Future<void> _updateServices(Task task) async {
    final tasks = state.valueOrNull ?? [];
    await WidgetService.updateWidgetData(
      tasks.where((t) => !t.isDeleted).toList(),
    );
    if (!kIsWeb) {
      if (!task.isCompleted && !task.isDeleted) {
        await NotificationService.instance.scheduleNotification(task);
      } else {
        await NotificationService.instance.cancelNotification(task.id);
      }
    }
  }
}

// 전체 Task 리스트를 관리하는 메인 Provider
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  () {
    return TaskListNotifier();
  },
);

// 활성화된(삭제되지 않은) Task만 필터링하여 제공하는 Provider
final activeTasksProvider = Provider<List<Task>>((ref) {
  final asyncTasks = ref.watch(taskListProvider);
  return asyncTasks.maybeWhen(
    data: (tasks) => tasks.where((task) => !task.isDeleted).toList(),
    orElse: () => [],
  );
});

// 삭제된 Task만 필터링하여 제공하는 Provider
final deletedTasksProvider = Provider<List<Task>>((ref) {
  final asyncTasks = ref.watch(taskListProvider);
  return asyncTasks.maybeWhen(
    data: (tasks) => tasks.where((task) => task.isDeleted).toList(),
    orElse: () => [],
  );
});
