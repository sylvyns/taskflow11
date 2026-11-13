import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Мягкое поле ввода.
InputDecoration softInput(String label, {IconData? icon, String? hint, Widget? suffix}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Pastel.outline),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: Pastel.inkSoft),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(borderSide: const BorderSide(color: Pastel.lavender, width: 1.6)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

