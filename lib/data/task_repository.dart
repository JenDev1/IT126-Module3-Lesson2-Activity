import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/task.dart';

/// Owns database initialization and all task CRUD operations.
class TaskRepository {
  TaskRepository._();

  static final TaskRepository instance = TaskRepository._();
  Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite through sqflite is not supported in a Chrome/web run. '
        'Run this project on Android, iOS, macOS, Windows, or Linux.',
      );
    }
    if (_database != null) return _database!;

    // sqflite uses the platform implementation on Android, iOS and macOS.
    // The FFI implementation enables local SQLite on Windows and Linux.
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databaseDirectory = await getDatabasesPath();
    final databasePath = p.join(databaseDirectory, 'student_tasks.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<Task>> getAll() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'id DESC');
    return rows.map(Task.fromMap).toList();
  }

  Future<int> create(String title) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }
    final db = await database;
    return db.insert('tasks', {'title': cleanTitle});
  }

  Future<void> setCompleted(Task task, bool completed) async {
    final db = await database;
    await db.update(
      'tasks',
      {'is_completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
