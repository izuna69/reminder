import 'package:flutter/foundation.dart';

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
  final bool isDeleted; // isDeleted 속성 추가
  final bool isAlarmEnabled;

  const Task({
    required this.id,
    required this.title,
    this.details = const [],
    required this.dueDate,
    this.isCompleted = false,
    this.isDeleted = false, // 생성자에 추가
    this.isAlarmEnabled = true,
  });

  Task copyWith({
    int? id,
    String? title,
    List<ChecklistItem>? details,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isDeleted, // copyWith에 추가
    bool? isAlarmEnabled,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted, // copyWith에 추가
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
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
      isDeleted: json['isDeleted'] ?? false, // fromJson에 추가
      isAlarmEnabled: json['isAlarmEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details.map((i) => i.toJson()).toList(),
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isDeleted': isDeleted, // toJson에 추가
      'isAlarmEnabled': isAlarmEnabled,
    };
  }
}
