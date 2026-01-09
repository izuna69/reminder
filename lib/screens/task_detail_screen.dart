import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reminder/models/task.dart';
import 'package:reminder/providers/task_provider.dart';
import 'package:reminder/screens/add_edit_task_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskListProvider);

    return asyncTasks.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (tasks) {
        final latestTask = tasks.firstWhere(
          (t) => t.id == task.id,
          orElse: () => task,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(latestTask.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditTaskScreen(task: latestTask),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마감 기한: ${DateFormat('yyyy-MM-dd HH:mm').format(latestTask.dueDate)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 24),
                Text('상세 항목', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: latestTask.details.length,
                    buildDefaultDragHandles: false,
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      // [추가] 이동이 끝난 후 실제 데이터 순서를 변경하는 함수를 호출함
                      ref
                          .read(taskListProvider.notifier)
                          .reorderChecklistItem(
                            latestTask.id!,
                            oldIndex,
                            newIndex,
                          );
                    },
                    itemBuilder: (context, index) {
                      final item = latestTask.details[index];
                      return ListTile(
                        key: ValueKey('$index-${item.text}'),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              // 가로줄 3개(reorder) 아이콘
                              child: const Icon(
                                Icons.reorder,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Checkbox(
                              value: item.isDone,
                              onChanged: (bool? value) {
                                ref
                                    .read(taskListProvider.notifier)
                                    .toggleChecklistItem(latestTask.id!, index);
                              },
                            ),
                          ],
                        ),
                        title: Text(
                          item.text,
                          style: TextStyle(
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
