import 'package:hive/hive.dart';

import 'todo_status.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  /// Kept in sync with [status] for older stored records.
  @HiveField(2)
  bool isCompleted;

  /// Nullable in storage because older Hive records may omit this field.
  @HiveField(3)
  TodoStatus? status;

  @HiveField(4)
  DateTime? createdAt;

  @HiveField(5)
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    TodoStatus? status,
    DateTime? createdAt,
    this.completedAt,
  })  : status = status ??
            (isCompleted ? TodoStatus.done : TodoStatus.pending),
        createdAt = createdAt ?? DateTime.now();

  TodoStatus get resolvedStatus =>
      status ?? (isCompleted ? TodoStatus.done : TodoStatus.pending);

  DateTime get resolvedCreatedAt => createdAt ?? DateTime.now();

  /// Fixes legacy / partially-migrated Hive records that can leave null fields.
  void normalize() {
    status = resolvedStatus;
    createdAt = resolvedCreatedAt;
    isCompleted = status == TodoStatus.done;
    if (status != TodoStatus.done) {
      completedAt = null;
    } else {
      completedAt ??= DateTime.now();
    }
  }

  void applyStatus(TodoStatus newStatus) {
    status = newStatus;
    isCompleted = newStatus == TodoStatus.done;
    if (newStatus == TodoStatus.done) {
      completedAt ??= DateTime.now();
    } else {
      completedAt = null;
    }
  }
}
