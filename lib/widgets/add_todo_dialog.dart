import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../models/todo_status.dart';
import '../theme/app_colors.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _controller = TextEditingController();
  String? _errorText;
  TodoStatus _status = TodoStatus.pending;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorText = 'Please enter a title';
      });
      return;
    }

    context.read<TodoBloc>().add(AddTodo(title, status: _status));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New task',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a title and choose a starting status.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'What do you need to do?',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            Text(
              'Status',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoStatus.values.map((status) {
                final selected = _status == status;
                final color = AppColors.statusColor(status);
                final bg = AppColors.statusBackground(status);
                return ChoiceChip(
                  selected: selected,
                  label: Text(status.label),
                  avatar: Icon(
                    switch (status) {
                      TodoStatus.pending => Icons.schedule_rounded,
                      TodoStatus.inProgress => Icons.timelapse_rounded,
                      TodoStatus.done => Icons.check_circle_rounded,
                    },
                    size: 16,
                    color: selected ? Colors.white : color,
                  ),
                  selectedColor: color,
                  backgroundColor: bg,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color,
                    fontSize: 12,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _status = status;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Add task'),
        ),
      ],
    );
  }
}
