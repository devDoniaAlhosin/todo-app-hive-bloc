import 'package:equatable/equatable.dart';

import '../models/todo.dart';
import '../models/todo_status.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final TodoStatus? filter;

  const TodoLoaded(
    this.todos, {
    this.filter,
  });

  List<Todo> get visibleTodos {
    final filtered = filter == null
        ? List<Todo>.from(todos)
        : todos.where((todo) => todo.resolvedStatus == filter).toList();

    filtered.sort((a, b) {
      final statusOrder =
          a.resolvedStatus.index.compareTo(b.resolvedStatus.index);
      if (statusOrder != 0) return statusOrder;
      return b.resolvedCreatedAt.compareTo(a.resolvedCreatedAt);
    });
    return filtered;
  }

  int countByStatus(TodoStatus status) =>
      todos.where((todo) => todo.resolvedStatus == status).length;

  TodoLoaded copyWith({
    List<Todo>? todos,
    TodoStatus? filter,
    bool clearFilter = false,
  }) {
    return TodoLoaded(
      todos ?? this.todos,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }

  /// Fingerprint forces rebuilds when Hive objects are mutated in place.
  @override
  List<Object?> get props => [
        filter,
        todos
            .map(
              (todo) =>
                  '${todo.id}|${todo.resolvedStatus}|${todo.isCompleted}|${todo.completedAt}|${todo.title}',
            )
            .toList(),
      ];
}

class TodoFailure extends TodoState {
  final String message;

  const TodoFailure(this.message);

  @override
  List<Object?> get props => [message];
}
