import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../domain/entities/task_entity.dart';

/// Карточка задачи. Получает только Entity — ничего не знает о БД.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onFavorite,
    this.showProject = true,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool showProject;

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Pastel.ink),
                ),
              ),
              const SizedBox(width: 8),
              PriorityChip(task.priority, dense: true),
              IconButton(
                tooltip: task.isFavorite ? 'Убрать из избранного' : 'В избранное',
                onPressed: onFavorite,
                icon: Icon(
                  task.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: task.isFavorite ? Pastel.butter : Pastel.inkSoft,
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Pastel.inkSoft, fontSize: 13),
            ),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                StatusChip(task.status, dense: true),
                if (showProject)
                  SoftChip(
                    label: task.projectName,
                    colors: const ChipColors(Pastel.lavenderLight, Pastel.lavenderDeep),
                    icon: Icons.folder_outlined,
                    dense: true,
                  ),
                SoftChip(
                  label: overdue ? 'Просрочена · ${fmtDate(task.deadline)}' : fmtDate(task.deadline),
                  colors: overdue
                      ? const ChipColors(Pastel.roseLight, Pastel.roseDeep)
                      : const ChipColors(Color(0xFFF4F1F8), Pastel.inkSoft),
                  icon: Icons.event_outlined,
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (task.assigneeName != null) ...[
                UserAvatar(name: task.assigneeName!, radius: 11),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task.assigneeName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Pastel.ink),
                  ),
                ),
              ] else
                const Expanded(
                  child: Text('Без исполнителя', style: TextStyle(fontSize: 13, color: Pastel.inkSoft)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
