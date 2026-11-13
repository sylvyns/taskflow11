import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api_constants.dart';
import '../../src/data/datasources/favorites_local_data_source.dart';
import '../../src/data/datasources/project_local_data_source.dart';
import '../../src/data/datasources/task_local_data_source.dart';
import '../../src/data/datasources/task_remote_data_source.dart';
import '../../src/data/datasources/user_local_data_source.dart';
import '../../src/data/repositories/project_repository_impl.dart';
import '../../src/data/repositories/task_repository_impl.dart';
import '../../src/data/repositories/user_repository_impl.dart';
import '../../src/domain/repositories/project_repository.dart';
import '../../src/domain/repositories/task_repository.dart';
import '../../src/domain/repositories/user_repository.dart';
import '../../src/domain/usecases/projects/add_project_usecase.dart';
import '../../src/domain/usecases/projects/delete_project_usecase.dart';
import '../../src/domain/usecases/projects/get_projects_usecase.dart';
import '../../src/domain/usecases/tasks/add_task_usecase.dart';
import '../../src/domain/usecases/tasks/change_task_status_usecase.dart';
import '../../src/domain/usecases/tasks/delete_task_usecase.dart';
import '../../src/domain/usecases/tasks/fetch_server_tasks_usecase.dart';
import '../../src/domain/usecases/tasks/get_tasks_usecase.dart';
import '../../src/domain/usecases/tasks/import_tasks_usecase.dart';
import '../../src/domain/usecases/tasks/toggle_favorite_usecase.dart';
import '../../src/domain/usecases/users/add_user_usecase.dart';
import '../../src/domain/usecases/users/delete_user_usecase.dart';
import '../../src/domain/usecases/users/get_users_usecase.dart';
import '../../src/presentation/bloc/import/import_cubit.dart';
import '../../src/presentation/bloc/projects/projects_cubit.dart';
import '../../src/presentation/bloc/task_form/task_form_cubit.dart';
import '../../src/presentation/bloc/tasks/tasks_cubit.dart';
import '../../src/presentation/bloc/users/users_cubit.dart';
import '../database/app_database.dart';
import '../database/connection.dart';
import '../rest_client/error_simulator.dart';
import '../rest_client/rest_client.dart';

final getIt = GetIt.instance;

/// Все зависимости регистрируются ЗДЕСЬ, по порядку «снизу вверх»:
/// внешние библиотеки → DataSource → Repository → UseCase → Cubit.
Future<void> configureDependencies() async {
  // ---------- 1. Внешние зависимости ----------
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase(openConnection()));

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<ErrorSimulationInterceptor>(() => ErrorSimulationInterceptor());
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.timeout,
        receiveTimeout: ApiConstants.timeout,
      ),
    )..interceptors.add(getIt<ErrorSimulationInterceptor>()),
  );
  getIt.registerLazySingleton<RestClient>(() => RestClient(getIt()));

  // ---------- 2. Data sources ----------
  getIt.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ProjectLocalDataSource>(() => ProjectLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<TaskLocalDataSource>(() => TaskLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<FavoritesLocalDataSource>(() => FavoritesLocalDataSourceImpl(getIt()));

  // ---------- 3. Repositories ----------
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt()));
  getIt.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl(getIt()));
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: getIt(),
      remoteDataSource: getIt(),
      favoritesDataSource: getIt(),
    ),
  );

  // ---------- 4. Use cases ----------
  getIt.registerFactory(() => GetUsersUseCase(getIt()));
  getIt.registerFactory(() => AddUserUseCase(getIt()));
  getIt.registerFactory(() => DeleteUserUseCase(getIt()));

  getIt.registerFactory(() => GetProjectsUseCase(getIt()));
  getIt.registerFactory(() => AddProjectUseCase(getIt()));
  getIt.registerFactory(() => DeleteProjectUseCase(getIt()));

  getIt.registerFactory(() => GetTasksUseCase(getIt()));
  getIt.registerFactory(() => AddTaskUseCase(getIt()));
  getIt.registerFactory(() => ChangeTaskStatusUseCase(getIt()));
  getIt.registerFactory(() => DeleteTaskUseCase(getIt()));
  getIt.registerFactory(() => ToggleFavoriteUseCase(getIt()));
  getIt.registerFactory(() => FetchServerTasksUseCase(getIt()));
  getIt.registerFactory(() => ImportTasksUseCase(getIt()));

  // ---------- 5. Cubits (новый экземпляр для каждого экрана) ----------
  getIt.registerFactory(() => UsersCubit(getUsers: getIt(), addUser: getIt(), deleteUser: getIt()));
  getIt.registerFactory(() => ProjectsCubit(getProjects: getIt(), addProject: getIt(), deleteProject: getIt()));
  getIt.registerFactory(
    () => TasksCubit(getTasks: getIt(), changeStatus: getIt(), deleteTask: getIt(), toggleFavorite: getIt()),
  );
  getIt.registerFactory(() => TaskFormCubit(getProjects: getIt(), getUsers: getIt(), addTask: getIt()));
  getIt.registerFactory(() => ImportCubit(fetchServerTasks: getIt(), importTasks: getIt()));
}
