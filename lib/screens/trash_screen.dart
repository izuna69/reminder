import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder/providers/task_provider.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  bool _isEditMode = false;
  final Set<int> _selectedTaskIds = {};

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _selectedTaskIds.clear();
    });
  }

  void _onItemSelect(int taskId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedTaskIds.add(taskId);
      } else {
        _selectedTaskIds.remove(taskId);
      }
    });
  }

  void _onSelectAll(bool selectAll, List<int> allTaskIds) {
    setState(() {
      if (selectAll) {
        _selectedTaskIds.addAll(allTaskIds);
      } else {
        _selectedTaskIds.clear();
      }
    });
  }

  void _deleteSelected() {
    ref
        .read(taskListProvider.notifier)
        .permanentlyDeleteMultipleTasks(_selectedTaskIds.toList());
    _toggleEditMode();
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: const Text('휴지통'),
      actions: [TextButton(onPressed: _toggleEditMode, child: Text("전체선택"))],
    );
  }

  AppBar _buildEditAppBar(List<int> allTaskIds) {
    final bool areAllSelected =
        _selectedTaskIds.length == allTaskIds.length && allTaskIds.isNotEmpty;
    final bool isIndeterminate = _selectedTaskIds.isNotEmpty && !areAllSelected;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _toggleEditMode,
      ),
      title: Text('${_selectedTaskIds.length}개 선택됨'),
      actions: [
        Checkbox(
          tristate: true, // 부분 선택 상태를 허용
          value: areAllSelected ? true : (isIndeterminate ? null : false),
          onChanged: (value) {
            // 체크박스를 누르면 '전체 선택' 또는 '전체 해제' 수행
            _onSelectAll(!areAllSelected, allTaskIds);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final deletedTasks = ref.watch(deletedTasksProvider);
    final allTaskIds = deletedTasks.map((t) => t.id).toList();

    return Scaffold(
      appBar: _isEditMode
          ? _buildEditAppBar(allTaskIds)
          : _buildDefaultAppBar(),
      body: deletedTasks.isEmpty
          ? const Center(
              child: Text(
                '휴지통이 비어있습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: deletedTasks.length,
              itemBuilder: (context, index) {
                final task = deletedTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: _isEditMode
                      ? CheckboxListTile(
                          value: _selectedTaskIds.contains(task.id),
                          onChanged: (isSelected) =>
                              _onItemSelect(task.id, isSelected!),
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListTile(
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.restore_from_trash),
                                tooltip: '복원',
                                onPressed: () {
                                  ref
                                      .read(taskListProvider.notifier)
                                      .restoreTask(task.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                ), // New icon
                                tooltip: '삭제', // New tooltip
                                onPressed: () {
                                  ref
                                      .read(taskListProvider.notifier)
                                      .permanentlyDeleteTask(task.id);
                                },
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
      bottomNavigationBar: _isEditMode && _selectedTaskIds.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      '영구 삭제',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: _deleteSelected,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
