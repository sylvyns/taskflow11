import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/tasks/tasks_cubit.dart';
import '../bloc/tasks/tasks_state.dart';
import '../widgets/filter_chip_face.dart';
import '../widgets/task_card.dart';
import 'import_page.dart';
import 'task_form_page.dart';

/// Список задач: все задачи или задачи одного проекта ([projectId]).
class TasksPage extends StatelessWidget {
  const TasksPage({super.key, this.projectId, this.projectName});

  final int? projectId;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TasksCubit>()..init(projectId: projectId),
      child: _TasksView(projectId: projectId, projectName: projectName),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView({this.projectId, this.projectName});

  final int? projectId;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasksCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(projectName ?? 'Задачи'),
        actions: [
          if (projectId != null)
            IconButton(
              tooltip: 'Импорт задач с сервера',
              icon: const Icon(Icons.cloud_download_outlined),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ImportPage(projectId: projectId!, projectName: projectName ?? ''),
                  ),
                );
                cubit.load(showLoader: false);
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_fab',
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => TaskFormPage(initialProjectId: projectId)),
          );
          if (created == true) cubit.load(showLoader: false);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Задача'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: cubit.setSearch, // debounce внутри Cubit
              decoration: softInput('Поиск по названию и описанию', icon: Icons.search_rounded),
            ),
          ),
          const _Filters(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) => switch (state) {
                TasksInitial() || TasksLoading() => const LoadingView(),
                TasksError(:final message) => ErrorView(message: message, onRetry: cubit.load),
                TasksEmpty() => EmptyView(
                    icon: cubit.filter.favoritesOnly ? Icons.star_outline_rounded : Icons.inbox_outlined,
                    title: cubit.filter.favoritesOnly ? 'В избранном пусто' : 'Задач не найдено',
                    subtitle: cubit.filter.favoritesOnly
                        ? 'Нажмите ☆ на карточке задачи, чтобы добавить её сюда'
                        : 'Измените фильтры или создайте новую задачу',
                  ),
                TasksLoaded(:final tasks) => RefreshIndicator(
                    onRefresh: () => cubit.load(showLoader: false),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => TaskCard(
                        task: tasks[i],
                        showProject: projectId == null,
                        onTap: () => _showActions(context, tasks[i]),
                        onFavorite: () async {
                          final error = await cubit.toggleFavorite(tasks[i]);
                          if (error != null && context.mounted) showSnack(context, error, error: true);
                        },
                      ),
                    ),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Нижнее меню: смена статуса и удаление.
  Future<void> _showActions(BuildContext context, TaskEntity task) async {
    final cubit = context.read<TasksCubit>();
    final action = await showModalBottomSheet<_SheetAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Pastel.ink)),
              const SizedBox(height: 4),
              const Text('Изменить статус', style: TextStyle(color: Pastel.inkSoft)),
              const SizedBox(height: 8),
              for (final status in TaskStatus.values)
                ListTile(
                  leading: Icon(status.icon, color: status.colors.foreground),
                  title: Text(status.label),
                  trailing: status == task.status ? const Icon(Icons.check_rounded, color: Pastel.lavender) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onTap: () => Navigator.pop(sheetContext, _SheetAction(status: status)),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Pastel.rose),
                title: const Text('Удалить задачу', style: TextStyle(color: Pastel.roseDeep)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () => Navigator.pop(sheetContext, const _SheetAction(delete: true)),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    if (action.delete) {
      final ok = await confirmDialog(context, title: 'Удалить задачу?', message: task.title);
      if (!ok) return;
      final error = await cubit.deleteTask(task);
      if (context.mounted) showSnack(context, error ?? 'Задача удалена', error: error != null);
    } else if (action.status != null) {
      final error = await cubit.changeStatus(task, action.status!);
      if (error != null && context.mounted) showSnack(context, error, error: true);
    }
  }
}

class _SheetAction {
  const _SheetAction({this.status, this.delete = false});

  final TaskStatus? status;
  final bool delete;
}

/// Фильтры: статус + «Избранное» (новая функция).
class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    // Перестраиваемся при каждом новом состоянии, чтобы подсветить активный фильтр.
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, _) {
        final cubit = context.read<TasksCubit>();
        final filter = cubit.filter;
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FilterChipFace(
                icon: Icons.star_rounded,
                label: 'Избранное',
                active: filter.favoritesOnly,
                onTap: cubit.toggleFavoritesOnly,
              ),
              const SizedBox(width: 8),
              FilterChipFace(
                label: 'Все',
                active: filter.status == null,
                onTap: () => cubit.setStatus(null),
              ),
              for (final status in TaskStatus.values) ...[
                const SizedBox(width: 8),
                FilterChipFace(
                  icon: status.icon,
                  label: status.label,
                  active: filter.status == status,
                  onTap: () => cubit.setStatus(status),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
