import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../models/todo.dart';
import '../models/todo_status.dart';
import '../theme/app_colors.dart';
import '../utils/date_format.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final status = todo.resolvedStatus;
    final isDone = status == TodoStatus.done;
    final statusColor = AppColors.statusColor(status);
    final statusBg = AppColors.statusBackground(status);
    final createdAt = todo.resolvedCreatedAt;

    return Container(
      key: ValueKey('${todo.id}-${todo.resolvedStatus}-${todo.isCompleted}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: statusColor),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isDone,
                        onChanged: (_) {
                          context.read<TodoBloc>().add(ToggleTodo(todo.id));
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              todo.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                decoration:
                                    isDone ? TextDecoration.lineThrough : null,
                                color: isDone
                                    ? AppColors.inkSoft.withValues(alpha: 0.55)
                                    : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                PopupMenuButton<TodoStatus>(
                                  initialValue: status,
                                  onSelected: (value) {
                                    context.read<TodoBloc>().add(
                                          ChangeTodoStatus(
                                            id: todo.id,
                                            status: value,
                                          ),
                                        );
                                  },
                                  itemBuilder: (context) => TodoStatus.values
                                      .map(
                                        (value) => PopupMenuItem(
                                          value: value,
                                          child: Text(value.label),
                                        ),
                                      )
                                      .toList(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          switch (status) {
                                            TodoStatus.pending =>
                                              Icons.schedule_rounded,
                                            TodoStatus.inProgress =>
                                              Icons.timelapse_rounded,
                                            TodoStatus.done =>
                                              Icons.check_circle_rounded,
                                          },
                                          size: 16,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          status.label,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: statusColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  'Created ${formatDateTime(createdAt)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.inkSoft
                                        .withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (todo.completedAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Done at ${formatDateTime(todo.completedAt!)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.done,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          context.read<TodoBloc>().add(DeleteTodo(todo.id));
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.inkSoft.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
