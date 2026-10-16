import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bloc/todo_bloc.dart';
import 'bloc/todo_event.dart';
import 'models/todo.dart';
import 'models/todo_status.dart';
import 'repositories/todo_repository.dart';
import 'screens/todo_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TodoStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodoAdapter());
  }

  final todoBox = Hive.isBoxOpen(TodoRepository.boxName)
      ? Hive.box<Todo>(TodoRepository.boxName)
      : await Hive.openBox<Todo>(TodoRepository.boxName);

  runApp(MyApp(todoBox: todoBox));
}

class MyApp extends StatelessWidget {
  final Box<Todo> todoBox;

  const MyApp({super.key, required this.todoBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc(
        repository: TodoRepository(box: todoBox),
      )..add(const LoadTodos()),
      child: MaterialApp(
        title: 'Focus Todos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const TodoPage(),
      ),
    );
  }
}
