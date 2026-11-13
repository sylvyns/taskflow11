import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/users/add_user_usecase.dart';
import '../../../domain/usecases/users/delete_user_usecase.dart';
import '../../../domain/usecases/users/get_users_usecase.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({
    required GetUsersUseCase getUsers,
    required AddUserUseCase addUser,
    required DeleteUserUseCase deleteUser,
  })  : _getUsers = getUsers,
        _addUser = addUser,
        _deleteUser = deleteUser,
        super(const UsersInitial());

  final GetUsersUseCase _getUsers;
  final AddUserUseCase _addUser;
  final DeleteUserUseCase _deleteUser;

  bool _isLoading = false;

  /// [showLoader] = false — обновить список «тихо», без спиннера.
  Future<void> load({bool showLoader = true}) async {
    if (_isLoading) return; // защита от повторного запроса
    _isLoading = true;
    if (showLoader) emit(const UsersLoading());

    final result = await _getUsers();
    _isLoading = false;
    if (isClosed) return;

    result.fold<void>(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(users.isEmpty ? const UsersEmpty() : UsersLoaded(users)),
    );
  }

  /// Возвращает текст ошибки или null, если всё прошло успешно.
  Future<String?> addUser({required String name, required String email}) async {
    final result = await _addUser(name: name, email: email);
    return result.fold<String?>((failure) => failure.message, (_) {
      load(showLoader: false);
      return null;
    });
  }

  Future<String?> deleteUser(int id) async {
    final result = await _deleteUser(id);
    return result.fold<String?>((failure) => failure.message, (_) {
      load(showLoader: false);
      return null;
    });
  }
}
