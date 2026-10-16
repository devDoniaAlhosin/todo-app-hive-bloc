import 'package:hive/hive.dart';

part 'todo_status.g.dart';

@HiveType(typeId: 1)
enum TodoStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

extension TodoStatusX on TodoStatus {
  String get label => switch (this) {
        TodoStatus.pending => 'Pending',
        TodoStatus.inProgress => 'In Progress',
        TodoStatus.done => 'Done',
      };

  String get shortLabel => switch (this) {
        TodoStatus.pending => 'Pending',
        TodoStatus.inProgress => 'Active',
        TodoStatus.done => 'Done',
      };
}
