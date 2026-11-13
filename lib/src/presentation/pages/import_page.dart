import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../domain/entities/enums.dart';
import '../bloc/import/import_cubit.dart';
import '../bloc/import/import_state.dart';
import '../widgets/error_simulation_selector.dart';

/// Импорт задач с сервера (jsonplaceholder) в проект.
/// Здесь видны все состояния: Loading, Success, Empty, Error + повтор.
class ImportPage extends StatelessWidget {
  const ImportPage({super.key, required this.projectId, required this.projectName});

  final int projectId;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ImportCubit>()..load(),
      child: _ImportView(projectId: projectId, projectName: projectName),
    );
  }
}

class _ImportView extends StatefulWidget {
  const _ImportView({required this.projectId, required this.projectName});

  final int projectId;
  final String projectName;

  @override
  State<_ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<_ImportView> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final error = await context.read<ImportCubit>().saveTo(widget.projectId);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showSnack(context, error, error: true);
    } else {
      showSnack(context, 'Задачи добавлены в «${widget.projectName}»');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт с сервера'),
        actions: [
          IconButton(
            tooltip: 'Загрузить другие задачи',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => cubit.load(force: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Проект: ${widget.projectName}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Pastel.ink),
                ),
                const SizedBox(height: 12),
                const ErrorSimulationSelector(),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ImportCubit, ImportState>(
              builder: (context, state) => switch (state) {
                ImportInitial() || ImportLoading() => const LoadingView(),
                ImportError(:final message) => ErrorView(message: message, onRetry: () => cubit.load(force: true)),
                ImportEmpty() => EmptyView(
                    icon: Icons.inbox_outlined,
                    title: 'Сервер не вернул задач',
                    action: OutlinedButton(
                      onPressed: () => cubit.load(force: true),
                      child: const Text('Обновить'),
                    ),
                  ),
                ImportLoaded(:final tasks) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final status = tasks[i].isCompleted ? TaskStatus.done : TaskStatus.todo;
                      return SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(tasks[i].title, style: const TextStyle(color: Pastel.ink)),
                            ),
                            const SizedBox(width: 8),
                            StatusChip(status, dense: true),
                          ],
                        ),
                      );
                    },
                  ),
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<ImportCubit, ImportState>(
        builder: (context, state) {
          if (state is! ImportLoaded) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_done_rounded),
                label: Text('Добавить ${state.tasks.length} задач в проект'),
              ),
            ),
          );
        },
      ),
    );
  }
}
