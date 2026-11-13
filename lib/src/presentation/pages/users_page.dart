import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/users/users_cubit.dart';
import '../bloc/users/users_state.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UsersCubit>()..load(),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UsersCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Люди')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'users_fab',
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Человек'),
      ),
      body: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) => switch (state) {
          UsersInitial() || UsersLoading() => const LoadingView(),
          UsersError(:final message) => ErrorView(message: message, onRetry: cubit.load),
          UsersEmpty() => const EmptyView(
              icon: Icons.people_outline_rounded,
              title: 'Пользователей пока нет',
              subtitle: 'Добавьте людей, чтобы назначать им задачи',
            ),
          UsersLoaded(:final users) => RefreshIndicator(
              onRefresh: () => cubit.load(showLoader: false),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _UserTile(user: users[i]),
              ),
            ),
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final cubit = context.read<UsersCubit>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новый пользователь'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: softInput('Имя', icon: Icons.person_outline_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: softInput('Email', icon: Icons.alternate_email_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final error = await cubit.addUser(name: nameController.text, email: emailController.text);
              if (!dialogContext.mounted) return;
              if (error != null) {
                showSnack(dialogContext, error, error: true);
              } else {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) showSnack(context, 'Пользователь добавлен');
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          UserAvatar(name: user.name, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Pastel.ink)),
                Text(user.email, style: const TextStyle(fontSize: 13, color: Pastel.inkSoft)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Удалить',
            icon: const Icon(Icons.delete_outline_rounded, color: Pastel.rose),
            onPressed: () async {
              final cubit = context.read<UsersCubit>();
              final ok = await confirmDialog(context, title: 'Удалить пользователя?', message: user.name);
              if (!ok) return;
              final error = await cubit.deleteUser(user.id);
              if (context.mounted) showSnack(context, error ?? 'Пользователь удалён', error: error != null);
            },
          ),
        ],
      ),
    );
  }
}
