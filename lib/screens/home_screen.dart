import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reminder/providers/task_provider.dart';
import 'package:reminder/providers/theme_provider.dart';
import 'package:reminder/screens/add_edit_task_screen.dart';
import 'package:reminder/screens/task_detail_screen.dart';

// 홈 화면 위젯
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // taskListProvider는 이제 동기적으로 List<Task>를 반환합니다.
    final tasks = ref.watch(taskListProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('리마인더'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: '테마 변경',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 50,
              child: const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text("메늉"),
              ),
            ),
          ],
        ),
      ),
      body: tasks.isEmpty
          // 할 일 목록이 비어있을 경우
          ? const Center(
              child: Text(
                '첫 할 일을 추가해보세요!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          // 할 일 목록이 있을 경우
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    onTap: () {
                      // 상세 보기 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        // 완료 상태 변경
                        ref
                            .read(taskListProvider.notifier)
                            .toggleComplete(task);
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      // 날짜 포맷 지정 (intl 패키지 필요)
                      DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // 할 일 삭제
                        ref
                            .read(taskListProvider.notifier)
                            .deleteTask(task.id!);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 할 일 추가 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: '할 일 추가',
      ),
    );
  }
}
