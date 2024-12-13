import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool completed;

  const TodoItem({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });

  @override
  List<Object?> get props => [id, title, description, completed];

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return TodoItem(
      id: id ?? this.id, // Only update id if explicitly provided
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}
