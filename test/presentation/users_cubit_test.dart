import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/src/domain/entities/user_entity.dart';
import 'package:taskflow/src/domain/usecases/users/add_user_usecase.dart';
import 'package:taskflow/src/domain/usecases/users/delete_user_usecase.dart';
import 'package:taskflow/src/domain/usecases/users/get_users_usecase.dart';
import 'package:taskflow/src/presentation/bloc/users/users_cubit.dart';
import 'package:taskflow/src/presentation/bloc/users/users_state.dart';

import '../fakes.dart';

UsersCubit _cubit(FakeUserRepository repo) => UsersCubit(
      getUsers: GetUsersUseCase(repo),
      addUser: AddUserUseCase(repo),
      deleteUser: DeleteUserUseCase(repo),
    );

void main() {
  test('пустой список → Loading, затем Empty', () async {
    final cubit = _cubit(FakeUserRepository());
    final states = <UsersState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    expect(states.map((s) => s.runtimeType).toList(), [UsersLoading, UsersEmpty]);
    await sub.cancel();
    await cubit.close();
  });

  test('есть данные → Loaded', () async {
    final repo = FakeUserRepository()
      ..users = [UserEntity(id: 1, name: 'Аня', email: 'a@a.kz', registeredAt: DateTime(2026))];
    final cubit = _cubit(repo);
    await cubit.load();
    expect(cubit.state, isA<UsersLoaded>());
    await cubit.close();
  });

  test('ошибка → Error с понятным текстом', () async {
    final repo = FakeUserRepository()..failure = const NetworkFailure();
    final cubit = _cubit(repo);
    await cubit.load();
    expect(cubit.state, isA<UsersError>());
    expect((cubit.state as UsersError).message, const NetworkFailure().message);
    await cubit.close();
  });
}
