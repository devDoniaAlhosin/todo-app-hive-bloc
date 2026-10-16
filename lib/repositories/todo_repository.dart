import 'package:hive_flutter/hive_flutter.dart';

import '../models/todo.dart';

class TodoRepository {
  /// New box name avoids crashing on old todos saved before statuses existed.
  static const String boxName = 'todos_v2';

  Box<Todo>? _box;

  TodoRepository({Box<Todo>? box}) : _box = box;

  /// Opens the box if it was closed (common after hot reload/restart glitches).
  Future<Box<Todo>> ensureBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<Todo>(boxName);
      return _box!;
    }
    _box = await Hive.openBox<Todo>(boxName);
    return _box!;
  }

  Future<List<Todo>> getAll() async {
    final box = await ensureBox();
    final todos = box.values.toList();
    for (final todo in todos) {
      todo.normalize();
    }
    return todos;
  }

  Future<void> add(Todo todo) async {
    final box = await ensureBox();
    todo.normalize();
    await box.put(todo.id, todo);
  }

  Future<void> update(Todo todo) async {
    final box = await ensureBox();
    todo.normalize();
    await box.put(todo.id, todo);
  }

  Future<void> delete(String id) async {
    final box = await ensureBox();
    await box.delete(id);
  }
}
