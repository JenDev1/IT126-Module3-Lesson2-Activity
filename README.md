# IT 126 – Module 3, Lesson 2: Local Task Manager

**Application:** Developing a Local Task Manager  
**Technology:** Flutter, Dart, SQLite (`sqflite`), `path`, and a repository pattern

## Application overview

This project implements the lesson's SQLite-based task manager. It stores tasks in a local SQLite database instead of keeping them only in a Dart list. The database table is named `tasks` and has an automatically generated `id`, a required `title`, and an `is_completed` integer status (`0` = pending, `1` = completed).

### Features
- Add a task using the text field and Add button.
- Reject empty or whitespace-only task titles.
- Load saved tasks when the screen opens and refresh the list after successful changes.
- Mark tasks as completed or pending.
- Delete a task from SQLite.
- Show loading, empty, and error states; the app does not display a success message when an operation fails.
- Keep data-access operations in `TaskRepository`, separate from the UI.

## Project structure

```text
lib/
├── main.dart                  # Flutter UI and user interactions
├── models/
│   └── task.dart              # Task model and database-map conversion
└── data/
    └── task_repository.dart   # SQLite initialization and CRUD operations
```

## How the implementation works

1. `TaskRepository` opens `student_tasks.db` in the platform's application database directory using `getDatabasesPath()` and `path.join()`.
2. On first creation, SQLite creates the `tasks` table with `id INTEGER PRIMARY KEY AUTOINCREMENT`, `title TEXT NOT NULL`, and `is_completed INTEGER NOT NULL DEFAULT 0`.
3. The UI calls repository methods to create, read, update, and delete records. It does not execute database queries directly.
4. Database calls are asynchronous and awaited. After a successful change, the UI reloads the task list.
5. Task titles are trimmed and checked before insertion. Database errors are caught and surfaced to the user.

## Run the application

1. Install Flutter and configure an Android/iOS emulator or connect a supported device.
2. Open a terminal in the project folder.
3. Run:

   ```bash
   flutter pub get
   flutter run
   ```

The app uses `sqflite`, which is intended for supported native platforms and does not run in Chrome through a normal `flutter run -d chrome` session. The project also configures `sqflite_common_ffi` for Windows and Linux desktop. For the intended mobile submission, run on Android or iOS.

## Reflection

### 1. Why does the application use SQLite instead of relying only on a Dart list?

The application uses SQLite because a Dart list exists only in the running process and does not automatically preserve its records after the app is terminated. SQLite stores task records persistently in a local database file, so the tasks can be loaded again when the application is reopened. SQLite also provides structured queries and defined operations for creating, retrieving, updating, and deleting records.

### 2. What is the purpose of the primary key in the tasks table?

The `id` column is the primary key and is generated automatically for each task. It uniquely identifies each record, even when two tasks have the same title. The repository uses this ID in the `WHERE id = ?` condition when updating a task's completion status or deleting it, ensuring the operation targets the intended record.

### 3. How does the repository simplify the UI's interaction with the database?

`TaskRepository` centralizes database initialization and the CRUD methods (`getAll`, `create`, `setCompleted`, and `delete`). The UI calls these methods instead of opening SQLite or writing queries itself. This separation keeps the screen focused on input and presentation, avoids scattering database logic through widgets, and makes the data-access code easier to maintain and test.

### 4. What would happen if a task were removed from the displayed list but not deleted from SQLite?

The task would disappear from the current display only temporarily. Its record would remain in SQLite, so it could appear again when the app reloads the task list or is reopened. For this implementation, the delete action first removes the record through `TaskRepository.delete()` and then reloads the list after the database operation succeeds.

### 5. If the database schema later needed a new column for task priority, what parts of the application might need to change?

The database schema would need a versioned migration that adds a priority column to existing databases; simply changing the table-creation SQL would not update databases already created on a user's device. The `Task` model and its map conversion would need to include priority, and the repository might need to accept, save, and retrieve that value. The UI would also need controls to choose and display priority. The database version and migration logic should be updated carefully so existing tasks are preserved.

## References

- Flutter. (n.d.). *Persist data with SQLite*. https://docs.flutter.dev/cookbook/persistence/sqlite
- SQLite Consortium. (n.d.). *CREATE TABLE*. https://www.sqlite.org/lang_createtable.html
- Tekartik. (n.d.). *sqflite: Flutter plugin for SQLite*. https://pub.dev/packages/sqflite
- Dart. (n.d.). *Asynchronous programming: Futures, async, and await*. https://dart.dev/libraries/async/async-await

## Submission checklist

- [x] Flutter/Dart source for the SQLite task manager included
- [x] Reflection answers included in this README
- [ ] Run and test on a supported native device/emulator
- [ ] Push the complete project to a public GitHub repository
- [ ] Submit only the public GitHub repository URL
