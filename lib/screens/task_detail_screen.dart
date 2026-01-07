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
    // taskListProvider에서 최신 task 상태를 가져옵니다.
    // find a task by id
    final latestTask = ref.watch(taskListProvider).firstWhere((t) => t.id == task.id, orElse: () => task);


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
            Text(
              '상세 항목',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: latestTask.details.length,
                itemBuilder: (context, index) {
                  final item = latestTask.details[index];
                  return ListTile(
                    leading: Checkbox(
                      value: item.isDone,
                      onChanged: (bool? value) {
                        ref.read(taskListProvider.notifier).toggleChecklistItem(latestTask.id!, index);
                      },
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
  }
}
