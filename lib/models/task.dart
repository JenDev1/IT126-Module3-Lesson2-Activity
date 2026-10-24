class Task {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final bool isCompleted;

  factory Task.fromMap(Map<String, Object?> map) => Task(
        id: map['id'] as int,
        title: map['title'] as String,
        isCompleted: (map['is_completed'] as int) == 1,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'is_completed': isCompleted ? 1 : 0,
      };
}
