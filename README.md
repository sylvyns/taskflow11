# TaskFlow 🌸 — СРС 11: Clean Architecture

Проект из задания № 10 (управление проектами и задачами, Flutter + SQLite/Drift), переработанный по принципам **Clean Architecture**. Пастельная палитра та же: лаванда, мята, персик, пудровая роза, небесно-голубой и сливочный.

## Запуск

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # генерирует lib/core/database/app_database.g.dart
flutter run
flutter test                                               # тесты Domain, Cubit и обработки ошибок
```

> Если в папке остался старый `lib/data/database/app_database.g.dart` от задания № 10, удалите его: база теперь лежит в `lib/core/database/`.

---

## Структура

```
lib/
├── main.dart                     — запуск: configureDependencies() → runApp
├── components/                   — общие виджеты (SoftCard, чипы, Loading/Empty/Error, диалоги)
├── constants/                    — палитра Pastel, тема, адрес API
├── models/                       — DTO: RemoteTaskModel (JSON с сервера), TaskWithRelations / ProjectWithStats (JOIN из SQLite)
├── core/
│   ├── rest_client/              — RestClient (обёртка над Dio) + имитатор ошибок
│   ├── error/                    — exceptions (Data), failures (Domain/UI), error_handler (централизованно)
│   ├── database/                 — Drift: таблицы, AppDatabase, индексы
│   └── di/injection.dart         — GetIt: все зависимости в одном месте
└── src/
    ├── data/
    │   ├── datasources/          — Local (Drift, SharedPreferences) и Remote (Dio)
    │   ├── mapper/               — Model → Entity
    │   └── repositories/         — реализации репозиториев
    ├── domain/                   — чистый Dart: без Flutter, Dio, Drift
    │   ├── entities/             — UserEntity, ProjectEntity, TaskEntity, TaskFilter…
    │   ├── repositories/         — абстрактные репозитории
    │   └── usecases/             — одно бизнес-действие = один UseCase
    └── presentation/
        ├── bloc/                 — Cubit + состояния (Initial / Loading / Loaded / Empty / Error)
        ├── pages/                — экраны
        └── widgets/              — виджеты экранов (TaskCard, ProjectCard…)
```

### Как идёт запрос (на примере списка задач)

```
TasksPage → TasksCubit → GetTasksUseCase → TaskRepository (абстракция)
                                                  ↑ реализует
                                      TaskRepositoryImpl → TaskLocalDataSource (Drift)
                                                         → FavoritesLocalDataSource (SharedPreferences)
                                      ← List<TaskEntity> (через mapper)
```

* Зависимости направлены **внутрь**: Presentation и Data знают о Domain, Domain не знает ни о ком.
* Экраны не создают репозитории и DataSource — Cubit берётся из `getIt`.
* В UI попадают только **Entity**, а не модели БД или API.

---

## Бизнес-логика в Domain

| UseCase | Правило |
|---|---|
| `AddTaskUseCase` | нужен проект и название; дедлайн не в прошлом; у исполнителя ≤ 3 незавершённых задач на одну дату |
| `AddUserUseCase` | имя не пустое, email корректный |
| `DeleteUserUseCase` | нельзя удалить пользователя с незавершёнными задачами |
| `AddProjectUseCase` | название не пустое, ≤ 120 символов |
| `ImportTasksUseCase` | нельзя импортировать пустой список |

---

## Обработка ошибок

DataSource бросает **исключение**, репозиторий через `safeCall()` превращает его в **Failure**, Cubit показывает `failure.message`. Технический текст исключения уходит только в лог.

| Ситуация | Исключение (Data) | Failure (Domain/UI) |
|---|---|---|
| Нет интернета / таймаут | `NetworkException` | `NetworkFailure` |
| Ошибка сервера 500 | `ServerException` | `ServerFailure` |
| Ошибка авторизации 401 | `UnauthorizedException` | `UnauthorizedFailure` |
| Неверный запрос 400 / неверные данные | `BadRequestException` / `ValidationException` | `ValidationFailure` |
| Пустой результат | — | состояние **Empty** |
| Неизвестная ошибка | `UnknownException` / любая другая | `UnknownFailure` |

**Как показать это на защите:** Проекты → ⋮ у проекта → «Импорт с сервера» → в поле «Проверка ошибок» выбрать 400 / 401 / 500 / «Нет интернета» / «Пустой ответ» → нажать «Повторить». Interceptor Dio подменяет ответ сервера, и экран показывает нужное состояние.

---

## Состояния и повторные запросы

* Каждый Cubit: **Loading → Loaded / Empty / Error**, на Error есть кнопка «Повторить», на списках — pull-to-refresh.
* Повторные запросы не отправляются:
  * `UsersCubit` / `ProjectsCubit` — флаг `_isLoading`;
  * `TasksCubit` — поиск с debounce 400 мс, одинаковый фильтр не перезапрашивается, ответы на устаревшие запросы игнорируются;
  * `ImportCubit` — если задачи уже загружены, повторно не грузит (только по кнопке ↻).

---

## Remote DataSource

`TaskRemoteDataSource` загружает задачи с `https://jsonplaceholder.typicode.com/todos` (Dio через `RestClient`). Их можно добавить в выбранный проект — импорт выполняется одной транзакцией.

## ⭐ Новая функция — Избранное

Звёздочка на карточке задачи добавляет её в избранное, фильтр «Избранное» показывает только такие задачи. ID хранятся в `SharedPreferences` (`FavoritesLocalDataSource`), поэтому сохраняются после перезапуска. Нажатие на звёздочку меняет задачу прямо в текущем списке, без нового запроса к базе.

---

## Что упрощено по сравнению с заданием № 10

Чтобы архитектуру было легко объяснить, в переработанной версии оставлены основные функции: **проекты, задачи (поиск, фильтр по статусу, смена статуса, удаление), пользователи, импорт с сервера и избранное**. Экраны статистики, бенчмарка индексов, корзины, истории/Undo, комментариев и вложений не переносились. Схема базы осталась прежней (v2), поэтому старые данные открываются без потерь.
