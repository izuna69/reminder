import 'package:flutter/foundation.dart';

// RecurrenceRule 내에서 사용할 반복 유형 정의
enum RecurrenceType { none, daily, weekly, monthly, yearly }

@immutable
class RecurrenceRule {
  final RecurrenceType type;
  // 주간 반복 시 사용 (1: 월요일, 7: 일요일)
  final List<int> daysOfWeek;

  const RecurrenceRule({
    this.type = RecurrenceType.none,
    this.daysOfWeek = const [],
  });

  RecurrenceRule copyWith({
    RecurrenceType? type,
    List<int>? daysOfWeek,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      type: RecurrenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecurrenceType.none,
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'daysOfWeek': daysOfWeek,
    };
  }

  // 반복 규칙이 설정되었는지 확인하는 getter
  bool get isEnabled => type != RecurrenceType.none;
}

@immutable
class ChecklistItem {
  final String text;
  final bool isDone;

  const ChecklistItem({required this.text, this.isDone = false});

  ChecklistItem copyWith({String? text, bool? isDone}) {
    return ChecklistItem(
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      text: json['text'],
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isDone': isDone,
    };
  }
}

@immutable
class Task {
  final int id;
  final String title;
  final List<ChecklistItem> details;
  final DateTime dueDate;
  final bool isCompleted;
  final bool isDeleted;
  final bool isAlarmEnabled;
  final RecurrenceRule recurrenceRule;

  const Task({
    required this.id,
    required this.title,
    this.details = const [],
    required this.dueDate,
    this.isCompleted = false,
    this.isDeleted = false,
    this.isAlarmEnabled = true,
    this.recurrenceRule = const RecurrenceRule(),
  });

  Task copyWith({
    int? id,
    String? title,
    List<ChecklistItem>? details,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isDeleted,
    bool? isAlarmEnabled,
    RecurrenceRule? recurrenceRule,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    var detailsFromJson = json['details'] as List;
    List<ChecklistItem> detailsList =
        detailsFromJson.map((i) => ChecklistItem.fromJson(i)).toList();

    return Task(
      id: json['id'],
      title: json['title'],
      details: detailsList,
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      isDeleted: json['isDeleted'] ?? false,
      isAlarmEnabled: json['isAlarmEnabled'] ?? true,
      recurrenceRule: json['recurrenceRule'] != null
          ? RecurrenceRule.fromJson(json['recurrenceRule'])
          : const RecurrenceRule(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details.map((i) => i.toJson()).toList(),
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isDeleted': isDeleted,
      'isAlarmEnabled': isAlarmEnabled,
      'recurrenceRule': recurrenceRule.toJson(),
    };
  }
}
