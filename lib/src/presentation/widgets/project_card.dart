import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../../domain/entities/project_entity.dart';

enum ProjectAction { importTasks, delete }

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap, required this.onAction});

  final ProjectEntity project;
  final VoidCallback onTap;
  final ValueChanged<ProjectAction> onAction;

  @override
  Widget build(BuildContext context) {
    final percent = (project.progress * 100).round();
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: project.status.colors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.folder_rounded, color: project.status.colors.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Pastel.ink),
                ),
              ),
              ProjectStatusChip(project.status),
              PopupMenuButton<ProjectAction>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: onAction,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: ProjectAction.importTasks,
                    child: ListTile(leading: Icon(Icons.cloud_download_outlined), title: Text('Импорт с сервера')),
                  ),
                  PopupMenuItem(
                    value: ProjectAction.delete,
                    child: ListTile(leading: Icon(Icons.delete_outline_rounded), title: Text('Удалить')),
                  ),
                ],
              ),
            ],
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Pastel.inkSoft),
            ),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: project.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Pastel.lavenderLight,
            color: Pastel.mint,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$percent% · ${project.doneTasks} из ${project.totalTasks - project.cancelledTasks} задач',
                style: const TextStyle(fontSize: 12.5, color: Pastel.inkSoft),
              ),
              const Spacer(),
              const Icon(Icons.event_outlined, size: 14, color: Pastel.inkSoft),
              const SizedBox(width: 4),
              Text(
                project.endDate == null ? 'без срока' : 'до ${fmtDate(project.endDate!)}',
                style: const TextStyle(fontSize: 12.5, color: Pastel.inkSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
