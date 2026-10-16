import 'package:equatable/equatable.dart';

import '../models/todo_status.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {
  const LoadTodos();
}

class AddTodo extends TodoEvent {
  final String title;
  final TodoStatus status;

  const AddTodo(
    this.title, {
    this.status = TodoStatus.pending,
  });

  @override
  List<Object?> get props => [title, status];
}

class ChangeTodoStatus extends TodoEvent {
  final String id;
  final TodoStatus status;

  const ChangeTodoStatus({
    required this.id,
    required this.status,
  });

  @override
  List<Object?> get props => [id, status];
}

class ToggleTodo extends TodoEvent {
  final String id;

  const ToggleTodo(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteTodo extends TodoEvent {
  final String id;

  const DeleteTodo(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterTodos extends TodoEvent {
  final TodoStatus? status;

  /// `null` means show all todos.
  const FilterTodos(this.status);

  @override
  List<Object?> get props => [status];
}
