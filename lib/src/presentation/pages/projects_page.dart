import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../core/di/injection.dart';
import '../../domain/entities/project_entity.dart';
import '../bloc/projects/projects_cubit.dart';
import '../bloc/projects/projects_state.dart';
import '../widgets/project_card.dart';
import 'import_page.dart';
import 'tasks_page.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cubit берём из DI — экран не создаёт репозитории сам.
    return BlocProvider(
      create: (_) => getIt<ProjectsCubit>()..load(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProjectsCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Проекты')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects_fab',
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Проект'),
      ),
      body: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) => switch (state) {
          ProjectsInitial() || ProjectsLoading() => const LoadingView(),
          ProjectsError(:final message) => ErrorView(message: message, onRetry: cubit.load),
          ProjectsEmpty() => const EmptyView(
              icon: Icons.folder_open_rounded,
              title: 'Проектов пока нет',
              subtitle: 'Нажмите «+ Проект», чтобы создать первый',
            ),
          ProjectsLoaded(:final projects) => RefreshIndicator(
              onRefresh: () => cubit.load(showLoader: false),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => ProjectCard(
                  project: projects[i],
                  onTap: () => _openTasks(context, projects[i]),
                  onAction: (action) => _onAction(context, projects[i], action),
                ),
              ),
            ),
        },
      ),
    );
  }

  Future<void> _openTasks(BuildContext context, ProjectEntity project) async {
    final cubit = context.read<ProjectsCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TasksPage(projectId: project.id, projectName: project.name)),
    );
    cubit.load(showLoader: false); // прогресс проекта мог измениться
  }

  Future<void> _onAction(BuildContext context, ProjectEntity project, ProjectAction action) async {
    final cubit = context.read<ProjectsCubit>();
    switch (action) {
      case ProjectAction.importTasks:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ImportPage(projectId: project.id, projectName: project.name)),
        );
        cubit.load(showLoader: false);
      case ProjectAction.delete:
        final ok = await confirmDialog(
          context,
          title: 'Удалить проект?',
          message: '«${project.name}» и все его задачи будут удалены.',
        );
        if (!ok) return;
        final error = await cubit.deleteProject(project.id);
        if (context.mounted) showSnack(context, error ?? 'Проект удалён', error: error != null);
    }
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final cubit = context.read<ProjectsCubit>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новый проект'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: softInput('Название', icon: Icons.folder_outlined),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: softInput('Описание', icon: Icons.notes_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final error = await cubit.addProject(
                name: nameController.text,
                description: descriptionController.text,
              );
              if (!dialogContext.mounted) return;
              if (error != null) {
                showSnack(dialogContext, error, error: true);
              } else {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) showSnack(context, 'Проект создан');
  }
}
