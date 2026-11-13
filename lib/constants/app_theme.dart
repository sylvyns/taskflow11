import 'package:flutter/material.dart';

import '../src/domain/entities/enums.dart';
import 'app_colors.dart';

/// Тема и цвета для статусов/приоритетов — та же пастельная палитра, что в задании №10.
extension TaskStatusStyle on TaskStatus {
  ChipColors get colors => switch (this) {
        TaskStatus.todo => const ChipColors(Pastel.skyLight, Pastel.skyDeep),
        TaskStatus.inProgress => const ChipColors(Pastel.peachLight, Pastel.peachDeep),
        TaskStatus.done => const ChipColors(Pastel.mintLight, Pastel.mintDeep),
        TaskStatus.cancelled => const ChipColors(Pastel.mauveLight, Pastel.mauveDeep),
      };

  IconData get icon => switch (this) {
        TaskStatus.todo => Icons.radio_button_unchecked_rounded,
        TaskStatus.inProgress => Icons.timelapse_rounded,
        TaskStatus.done => Icons.check_circle_outline_rounded,
        TaskStatus.cancelled => Icons.block_rounded,
      };
}

extension TaskPriorityStyle on TaskPriority {
  ChipColors get colors => switch (this) {
        TaskPriority.low => const ChipColors(Pastel.mintLight, Pastel.mintDeep),
        TaskPriority.medium => const ChipColors(Pastel.skyLight, Pastel.skyDeep),
        TaskPriority.high => const ChipColors(Pastel.butterLight, Pastel.butterDeep),
        TaskPriority.critical => const ChipColors(Pastel.roseLight, Pastel.roseDeep),
      };

  /// Насыщенный (но всё ещё мягкий) цвет для полос графиков.
  Color get barColor => switch (this) {
        TaskPriority.low => Pastel.mint,
        TaskPriority.medium => Pastel.sky,
        TaskPriority.high => Pastel.butter,
        TaskPriority.critical => Pastel.rose,
      };

  IconData get icon => switch (this) {
        TaskPriority.low => Icons.keyboard_double_arrow_down_rounded,
        TaskPriority.medium => Icons.drag_handle_rounded,
        TaskPriority.high => Icons.keyboard_arrow_up_rounded,
        TaskPriority.critical => Icons.priority_high_rounded,
      };
}

extension ProjectStatusStyle on ProjectStatus {
  ChipColors get colors => switch (this) {
        ProjectStatus.active => const ChipColors(Pastel.lavenderLight, Pastel.lavenderDeep),
        ProjectStatus.completed => const ChipColors(Pastel.mintLight, Pastel.mintDeep),
        ProjectStatus.archived => const ChipColors(Pastel.mauveLight, Pastel.mauveDeep),
      };
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: Pastel.lavender).copyWith(
      primary: Pastel.lavender,
      onPrimary: Colors.white,
      primaryContainer: Pastel.lavenderLight,
      onPrimaryContainer: Pastel.lavenderDeep,
      secondary: Pastel.mint,
      onSecondary: Colors.white,
      secondaryContainer: Pastel.mintLight,
      onSecondaryContainer: Pastel.mintDeep,
      tertiary: Pastel.peach,
      onTertiary: Colors.white,
      tertiaryContainer: Pastel.peachLight,
      onTertiaryContainer: Pastel.peachDeep,
      error: const Color(0xFFD06A7C),
      onError: Colors.white,
      errorContainer: Pastel.roseLight,
      onErrorContainer: Pastel.roseDeep,
      surface: Pastel.background,
      onSurface: Pastel.ink,
      onSurfaceVariant: Pastel.inkSoft,
      outline: const Color(0xFFD9CFE8),
      outlineVariant: Pastel.outline,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFBF9FE),
      surfaceContainer: const Color(0xFFF5F1FB),
      surfaceContainerHigh: const Color(0xFFF2EDF9),
      surfaceContainerHighest: const Color(0xFFECE6F5),
    );

    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Pastel.background,
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: Pastel.lavenderLight,
        side: const BorderSide(color: Pastel.outline),
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(color: Pastel.ink, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Pastel.lavenderLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Pastel.ink),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Pastel.lavenderLight,
        foregroundColor: Pastel.lavenderDeep,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: rounded,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: rounded,
          side: const BorderSide(color: Pastel.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: rounded, foregroundColor: Pastel.lavenderDeep),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Pastel.lavenderDeep,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: Pastel.outline, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Pastel.lavender),
    );
  }
}
