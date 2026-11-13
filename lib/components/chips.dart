import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../src/domain/entities/enums.dart';

class SoftChip extends StatelessWidget {
  const SoftChip({super.key, required this.label, required this.colors, this.icon, this.dense = false});

  final String label;
  final ChipColors colors;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 13 : 15, color: colors.foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: colors.foreground, fontSize: dense ? 11.5 : 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.dense = false});

  final TaskStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) =>
      SoftChip(label: status.label, colors: status.colors, icon: status.icon, dense: dense);
}

class PriorityChip extends StatelessWidget {
  const PriorityChip(this.priority, {super.key, this.dense = false});

  final TaskPriority priority;
  final bool dense;

  @override
  Widget build(BuildContext context) =>
      SoftChip(label: priority.label, colors: priority.colors, icon: priority.icon, dense: dense);
}

class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip(this.status, {super.key});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) => SoftChip(label: status.label, colors: status.colors);
}

