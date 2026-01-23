import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reminder/providers/task_provider.dart';
import 'package:reminder/providers/theme_provider.dart';
import 'package:reminder/screens/add_edit_task_screen.dart';
import 'package:reminder/screens/task_detail_screen.dart';
import 'package:reminder/screens/trash_screen.dart';
import 'package:reminder/screens/settings_screen.dart'; // 설정 화면 파일을 불러옴

// 홈 화면 위젯
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 활성화된(삭제되지 않은) task 목록 감시
    final tasks = ref.watch(activeTasksProvider);
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
            SizedBox( // const를 뺐습니다.
              height: 65,
              child: DrawerHeader(
                // Colors.blueAccent 대신 테마 색상을 불러오도록 수정
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                // 배경색에 맞춰 글자색도 바뀌도록 스타일만 추가
                child: Text("메뉴", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('휴지통'),
              onTap: () {
                Navigator.of(context).pop(); // Drawer 닫기
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TrashScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('설정'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }, // ← 여기가 64번 줄 근처가 됩니다.
            ),
          ],
        ),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                '첫 할 일을 추가해보세요!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          // 순서 변경 기능을 제거하고 일반 ListView.builder로 복구함
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                    onLongPress: () {
                      ref.read(taskListProvider.notifier).deleteTask(task.id);
                    },

                    leading: Checkbox(
                      value: task.isCompleted,

                      onChanged: (bool? value) {
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
                      DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        ref.read(taskListProvider.notifier).deleteTask(task.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
