import 'package:flutter/foundation.dart';

/// 개별 체크리스트 항목을 나타내는 클래스
@immutable
class ChecklistItem {
  const ChecklistItem({
    required this.text,
    this.isDone = false,
  });

  final String text;
  final bool isDone;

  // JSON 직렬화/역직렬화를 위한 팩토리 생성자 및 메서드
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      text: json['text'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isDone': isDone,
    };
  }

  // 객체의 불변성을 유지하며 특정 속성만 변경하기 위한 copyWith 메서드
  ChecklistItem copyWith({
    String? text,
    bool? isDone,
  }) {
    return ChecklistItem(
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}

/// 할 일(Task)을 나타내는 메인 모델 클래스
@immutable
class Task {
  const Task({
    this.id,
    required this.title,
    this.details = const [],
    required this.dueDate,
    this.isCompleted = false,
  });

  final int? id; // 데이터베이스에서 자동 증가될 ID
  final String title;
  final List<ChecklistItem> details;
  final DateTime dueDate;
  final bool isCompleted;

  // JSON 직렬화/역직렬화
  factory Task.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List<dynamic>? ?? [];
    List<ChecklistItem> checklist = detailsList
        .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      details: checklist,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details.map((item) => item.toJson()).toList(),
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // copyWith 메서드
  Task copyWith({
    int? id,
    String? title,
    List<ChecklistItem>? details,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
