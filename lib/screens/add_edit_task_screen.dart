import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reminder/models/task.dart';
import 'package:reminder/providers/task_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late List<ChecklistItem> _checklistItems;
  late List<TextEditingController> _checklistItemControllers;
  late bool _isAlarmEnabled;

  // New state variables for recurrence
  late RecurrenceType _recurrenceType;
  late List<bool> _selectedDays; // 0 = Monday, 6 = Sunday

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _checklistItems = List<ChecklistItem>.from(widget.task?.details ?? []);
    _checklistItemControllers = _checklistItems
        .map((item) => TextEditingController(text: item.text))
        .toList();
    _isAlarmEnabled = widget.task?.isAlarmEnabled ?? true;

    // Initialize new recurrence state
    final rule = widget.task?.recurrenceRule ?? const RecurrenceRule();
    _recurrenceType = rule.type;
    _selectedDays = List.generate(7, (index) {
      // daysOfWeek uses 1-7 for Mon-Sun. We use 0-6 for Mon-Sun.
      return rule.daysOfWeek.contains(index + 1);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _checklistItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addChecklistItem() {
    setState(() {
      _checklistItems.add(ChecklistItem(text: ''));
      _checklistItemControllers.add(TextEditingController());
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItemControllers[index].dispose();
      _checklistItems.removeAt(index);
      _checklistItemControllers.removeAt(index);
    });
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // --- Construct the RecurrenceRule ---
      RecurrenceRule newRule;
      if (_recurrenceType == RecurrenceType.weekly) {
        final List<int> selectedDaysList = [];
        for (int i = 0; i < _selectedDays.length; i++) {
          if (_selectedDays[i]) {
            selectedDaysList.add(i + 1); // Convert 0-6 index to 1-7 day
          }
        }
        // If user selected 'weekly' but no days, revert to 'none'
        if (selectedDaysList.isEmpty) {
          newRule = const RecurrenceRule(type: RecurrenceType.none);
        } else {
          newRule = RecurrenceRule(
            type: RecurrenceType.weekly,
            daysOfWeek: selectedDaysList,
          );
        }
      } else {
        // For none, daily, monthly, yearly
        newRule = RecurrenceRule(type: _recurrenceType);
      }
      // --- End of RecurrenceRule construction ---

      final updatedChecklist = List.generate(_checklistItemControllers.length, (
        index,
      ) {
        return ChecklistItem(
          text: _checklistItemControllers[index].text,
          isDone: _checklistItems[index].isDone,
        );
      });

      final isEditing = widget.task != null;

      if (isEditing) {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          details: updatedChecklist,
          dueDate: _selectedDate,
          isAlarmEnabled: _isAlarmEnabled,
          recurrenceRule: newRule, // Use new rule object
        );
        await ref.read(taskListProvider.notifier).updateTask(updatedTask);
      } else {
        final newTask = Task(
          id: 0,
          title: _titleController.text,
          details: updatedChecklist,
          dueDate: _selectedDate,
          isAlarmEnabled: _isAlarmEnabled,
          recurrenceRule: newRule, // Use new rule object
        );
        await ref.read(taskListProvider.notifier).addTask(newTask);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? '새 할 일 추가' : '할 일 편집'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('마감 기한'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              SwitchListTile(
                title: const Text('알람 활성화'),
                value: _isAlarmEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAlarmEnabled = value;
                  });
                },
              ),
              if (_isAlarmEnabled) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<RecurrenceType>(
                  value: _recurrenceType,
                  decoration: const InputDecoration(
                    labelText: '반복 유형',
                    border: OutlineInputBorder(),
                  ),
                  items: RecurrenceType.values.map((type) {
                    return DropdownMenuItem<RecurrenceType>(
                      value: type,
                      child: Text(
                        switch (type) {
                          RecurrenceType.none => '없음',
                          RecurrenceType.daily => '매일',
                          RecurrenceType.weekly => '매주 (요일 선택)',
                          RecurrenceType.monthly => '매월',
                          RecurrenceType.yearly => '매년',
                        },
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _recurrenceType = value;
                      });
                    }
                  },
                ),
                if (_recurrenceType == RecurrenceType.weekly)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 6.0,
                      alignment: WrapAlignment.center,
                      children: List.generate(7, (index) {
                        final dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
                        return FilterChip(
                          label: Text(dayLabels[index]),
                          selected: _selectedDays[index],
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedDays[index] = selected;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Text('상세 항목', style: Theme.of(context).textTheme.titleMedium),
              ...List.generate(_checklistItems.length, (index) {
                return Row(
                  children: [
                    SizedBox(height: 60),
                    Expanded(
                      child: TextFormField(
                        controller: _checklistItemControllers[index],
                        decoration: InputDecoration(
                          labelText: '항목 ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeChecklistItem(index),
                    ),
                  ],
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('항목 추가'),
                onPressed: _addChecklistItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
