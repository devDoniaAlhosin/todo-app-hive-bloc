import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../models/todo_status.dart';
import '../theme/app_colors.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  Future<void> _openAddDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TodoBloc>(),
        child: const AddTodoDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.ink,
              AppColors.inkSoft,
              AppColors.mistDeep,
              AppColors.mist,
            ],
            stops: [0, 0.22, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading || state is TodoInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is TodoFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              if (state is TodoLoaded) {
                final visible = state.visibleTodos;
                final doneCount = state.countByStatus(TodoStatus.done);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Focus Todos',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.todos.isEmpty
                                ? 'Plan your day. Add your first task.'
                                : '$doneCount of ${state.todos.length} completed',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterPill(
                              label: 'All',
                              count: state.todos.length,
                              selected: state.filter == null,
                              onTap: () => context
                                  .read<TodoBloc>()
                                  .add(const FilterTodos(null)),
                            ),
                            ...TodoStatus.values.map((status) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _FilterPill(
                                  label: status.label,
                                  count: state.countByStatus(status),
                                  selected: state.filter == status,
                                  accent: AppColors.statusColor(status),
                                  onTap: () => context
                                      .read<TodoBloc>()
                                      .add(FilterTodos(status)),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.mist,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: state.todos.isEmpty
                            ? const _EmptyState(
                                title: 'No todos yet',
                                subtitle: 'Tap + to capture your next task.',
                              )
                            : visible.isEmpty
                                ? const _EmptyState(
                                    title: 'Nothing here',
                                    subtitle:
                                        'No todos match this status filter.',
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      20,
                                      16,
                                      100,
                                    ),
                                    itemCount: visible.length,
                                    itemBuilder: (context, index) {
                                      return TodoTile(todo: visible[index]);
                                    },
                                  ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add task'),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color? accent;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (accent ?? AppColors.coral) : Colors.white;
    final fg = selected ? Colors.white : AppColors.inkSoft;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: (accent ?? AppColors.coral).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '$label ($count)',
            style: GoogleFonts.plusJakartaSans(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.mistDeep,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 36,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.inkSoft,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
