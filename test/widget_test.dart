import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:w9_assign_2_s18_todo_app/bloc/todo_bloc.dart';
import 'package:w9_assign_2_s18_todo_app/bloc/todo_event.dart';
import 'package:w9_assign_2_s18_todo_app/models/todo.dart';
import 'package:w9_assign_2_s18_todo_app/models/todo_status.dart';
import 'package:w9_assign_2_s18_todo_app/repositories/todo_repository.dart';
import 'package:w9_assign_2_s18_todo_app/screens/todo_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<Todo> todoBox;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('todo_hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TodoStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    todoBox = await Hive.openBox<Todo>(TodoRepository.boxName);
  });

  tearDown(() async {
    await todoBox.clear();
    await Hive.close();
  });

  testWidgets('Todo app shows Focus Todos title', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => TodoBloc(
          repository: TodoRepository(box: todoBox),
        )..add(const LoadTodos()),
        child: const MaterialApp(
          home: TodoPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Focus Todos'), findsOneWidget);
    expect(find.text('No todos yet'), findsOneWidget);
  });
}
