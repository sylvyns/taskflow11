import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../domain/entities/enums.dart';
import '../bloc/task_form/task_form_cubit.dart';
import '../bloc/task_form/task_form_state.dart';

/// Создание задачи. Проверки (пустое название, дедлайн, лимит исполнителя)
/// выполняет AddTaskUseCase в Domain-слое, а экран только показывает результат.
class TaskFormPage extends StatelessWidget {
  const TaskFormPage({super.key, this.initialProjectId});

  final int? initialProjectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskFormCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Новая задача')),
        body: BlocBuilder<TaskFormCubit, TaskFormState>(
          builder: (context, state) => switch (state) {
            TaskFormLoading() => const LoadingView(),
            TaskFormError(:final message) =>
              ErrorView(message: message, onRetry: context.read<TaskFormCubit>().load),
            TaskFormReady(:final projects) when projects.isEmpty => const EmptyView(
                icon: Icons.folder_open_rounded,
                title: 'Сначала создайте проект',
                subtitle: 'Задача обязательно принадлежит проекту',
              ),
            final TaskFormReady ready => _TaskForm(ready: ready, initialProjectId: initialProjectId),
          },
        ),
      ),
    );
  }
}

class _TaskForm extends StatefulWidget {
  const _TaskForm({required this.ready, this.initialProjectId});

  final TaskFormReady ready;
  final int? initialProjectId;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _projectId;
  int? _assigneeId;
  TaskPriority _priority = TaskPriority.medium;
  DateTime _deadline = DateTime.now().add(const Duration(days: 3));
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ids = widget.ready.projects.map((p) => p.id);
    _projectId = ids.contains(widget.initialProjectId) ? widget.initialProjectId : ids.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final error = await context.read<TaskFormCubit>().submit(
          projectId: _projectId,
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
          deadline: _deadline,
          assigneeId: _assigneeId,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showSnack(context, error, error: true);
    } else {
      showSnack(context, 'Задача создана');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _titleController,
          decoration: softInput('Название', icon: Icons.title_rounded),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: softInput('Описание', icon: Icons.notes_rounded),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _projectId,
          decoration: softInput('Проект', icon: Icons.folder_outlined),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          items: [
            for (final p in ready.projects) DropdownMenuItem(value: p.id, child: Text(p.name)),
          ],
          onChanged: (id) => setState(() => _projectId = id),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          value: _assigneeId,
          decoration: softInput('Исполнитель', icon: Icons.person_outline_rounded),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Без исполнителя')),
            for (final u in ready.users) DropdownMenuItem<int?>(value: u.id, child: Text(u.name)),
          ],
          onChanged: (id) => setState(() => _assigneeId = id),
        ),
        const SizedBox(height: 16),
        const Text('Приоритет', style: TextStyle(fontWeight: FontWeight.w600, color: Pastel.ink)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final p in TaskPriority.values)
              ChoiceChip(
                label: Text(p.label),
                selected: _priority == p,
                onSelected: (_) => setState(() => _priority = p),
              ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _pickDeadline,
          icon: const Icon(Icons.event_outlined),
          label: Text('Дедлайн: ${fmtDate(_deadline)}'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check_rounded),
          label: const Text('Создать задачу'),
        ),
      ],
    );
  }
}
