import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// «Таблетка» фильтра в пастельном стиле.
class FilterChipFace extends StatelessWidget {
  const FilterChipFace({super.key, required this.label, required this.active, required this.onTap, this.icon});

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Pastel.lavenderLight : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: active ? Pastel.lavender.withValues(alpha: 0.5) : Pastel.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: active ? Pastel.lavenderDeep : Pastel.inkSoft),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Pastel.lavenderDeep : Pastel.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
