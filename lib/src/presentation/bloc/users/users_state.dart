import '../../../domain/entities/user_entity.dart';

sealed class UsersState {
  const UsersState();
}

class UsersInitial extends UsersState {
  const UsersInitial();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  const UsersLoaded(this.users);

  final List<UserEntity> users;
}

class UsersEmpty extends UsersState {
  const UsersEmpty();
}

class UsersError extends UsersState {
  const UsersError(this.message);

  final String message;
}
