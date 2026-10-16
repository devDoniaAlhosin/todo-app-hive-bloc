import 'package:flutter/material.dart';

import '../models/todo_status.dart';

/// Focus Studio palette — ink, mist, and coral accents.
abstract final class AppColors {
  static const Color ink = Color(0xFF152238);
  static const Color inkSoft = Color(0xFF2A3A55);
  static const Color mist = Color(0xFFF3F6FA);
  static const Color mistDeep = Color(0xFFE4EBF4);
  static const Color coral = Color(0xFFE85D4C);
  static const Color coralDark = Color(0xFFC94636);
  static const Color card = Color(0xFFFFFFF8);
  static const Color line = Color(0xFFD5DEEA);

  static const Color pending = Color(0xFFD97706);
  static const Color pendingBg = Color(0xFFFFF4E5);
  static const Color inProgress = Color(0xFF2563EB);
  static const Color inProgressBg = Color(0xFFEAF1FF);
  static const Color done = Color(0xFF0F9F6E);
  static const Color doneBg = Color(0xFFE6F7F0);

  static Color statusColor(TodoStatus status) => switch (status) {
        TodoStatus.pending => pending,
        TodoStatus.inProgress => inProgress,
        TodoStatus.done => done,
      };

  static Color statusBackground(TodoStatus status) => switch (status) {
        TodoStatus.pending => pendingBg,
        TodoStatus.inProgress => inProgressBg,
        TodoStatus.done => doneBg,
      };
}
