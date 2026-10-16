import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';
import '../models/todo_status.dart';
import '../repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;
  final Uuid _uuid;

  TodoBloc({
    required this.repository,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<ChangeTodoStatus>(_onChangeTodoStatus);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<FilterTodos>(_onFilterTodos);
  }

  TodoStatus? get _currentFilter {
    final current = state;
    if (current is TodoLoaded) return current.filter;
    return null;
  }

  Future<void> _healLegacyTodos() async {
    final todos = await repository.getAll();
    for (final todo in todos) {
      todo.normalize();
      await repository.update(todo);
    }
  }

  Future<void> _emitLoaded(
    Emitter<TodoState> emit, {
    TodoStatus? filter,
    bool clearFilter = false,
  }) async {
    final nextFilter = clearFilter ? null : (filter ?? _currentFilter);
    emit(TodoLoaded(await repository.getAll(), filter: nextFilter));
  }

  /// If the active filter would hide the updated todo, follow it to the new status.
  TodoStatus? _filterAfterStatusChange(TodoStatus newStatus) {
    final current = _currentFilter;
    if (current == null) return null;
    if (current == newStatus) return current;
    return newStatus;
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(const TodoLoading());
    try {
      await repository.ensureBox();
      await _healLegacyTodos();
      await _emitLoaded(emit);
    } catch (e) {
      emit(TodoFailure(e.toString()));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      final now = DateTime.now();
      final todo = Todo(
        id: _uuid.v4(),
        title: event.title.trim(),
        status: event.status,
        createdAt: now,
        completedAt: event.status == TodoStatus.done ? now : null,
        isCompleted: event.status == TodoStatus.done,
      );
      await repository.add(todo);
      await _emitLoaded(
        emit,
        filter: _filterAfterStatusChange(event.status),
      );
    } catch (e) {
      emit(TodoFailure(e.toString()));
    }
  }

  Future<void> _onChangeTodoStatus(
    ChangeTodoStatus event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final todos = await repository.getAll();
      final todo = todos.firstWhere((t) => t.id == event.id);
      todo.applyStatus(event.status);
      await repository.update(todo);
      await _emitLoaded(
        emit,
        filter: _filterAfterStatusChange(event.status),
      );
    } catch (e) {
      emit(TodoFailure(e.toString()));
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    try {
      final todos = await repository.getAll();
      final todo = todos.firstWhere((t) => t.id == event.id);
      final next = todo.resolvedStatus == TodoStatus.done
          ? TodoStatus.pending
          : TodoStatus.done;
      todo.applyStatus(next);
      await repository.update(todo);
      await _emitLoaded(
        emit,
        filter: _filterAfterStatusChange(next),
      );
    } catch (e) {
      emit(TodoFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await repository.delete(event.id);
      await _emitLoaded(emit);
    } catch (e) {
      emit(TodoFailure(e.toString()));
    }
  }

  void _onFilterTodos(FilterTodos event, Emitter<TodoState> emit) {
    final current = state;
    if (current is! TodoLoaded) return;
    emit(current.copyWith(
      filter: event.status,
      clearFilter: event.status == null,
    ));
  }
}
