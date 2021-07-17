import 'dart:async';

import 'package:task_list_1/models/task.dart';
import 'package:task_list_1/src/tasks_fake_debug_data.dart';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:sqlite3/sqlite3.dart' hide Database;

import 'package:flutter/widgets.dart';

class DatabaseConnector {
  static Database? database;

  Future<void> init() async {
    bool createDB = false;
    final dbPath = join(await getDatabasesPath(), 'tasks_list.db');
    print("Connecting to database $dbPath");
    WidgetsFlutterBinding.ensureInitialized();
    final initSqlQuery =
        await rootBundle.loadString('assets/database_queries/db_init.sql');
    // print(initSqlQuery);
    database = await openDatabase(
      dbPath,
      onCreate: (db, version) async {
        createDB = true;
        return null;
      },
      version: 1,
    );
    if (createDB) {
      database!.close();
      final dbS3 = sqlite3.open(dbPath);
      print("creating db");
      dbS3.execute(initSqlQuery);
      dbS3.dispose();
      print("db created");
      database = await openDatabase(dbPath);
      for (final task in tasks) {
        database!.insert('tasks', task.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      print("Database initialized successfully");
    }
  }

  Future<void> checkConnection() async {
    if (database == null) {
      await this.init();
      if (database == null) {
        throw "Cannot connect to database";
      }
    }
  }

  Future<void> insertTask(Task task) async {
    await checkConnection();
    await database!.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await checkConnection();
    await database!
        .update('tasks', task.toMap(), where: "id = ?", whereArgs: [task.id]);
  }

  Future<void> deleteTask(int taskId) async {
    await checkConnection();
    await database!.delete('tasks', where: "id = ?", whereArgs: [taskId]);
  }

  Future<List<Task>> getTasks({DateTime? dayFilter}) async {
    await checkConnection();
    // dayFilter = DateTime.utc(2021, 06, 30);
    // print(DateFormat('yyyy-MM-dd').format(dayFilter));
    final List<Map<String, dynamic>> tasksMaps = (dayFilter != null)
        ? await database!.query('tasks',
            where: "date(planned_date) = ?",
            whereArgs: [DateFormat('yyyy-MM-dd').format(dayFilter)],
            orderBy: "planned_date")
        : await database!.query('tasks', orderBy: "planned_date");
    return List.generate(tasksMaps.length, (i) {
      // todo error management and null check
      return Task(
        id: tasksMaps[i]['id'],
        name: tasksMaps[i]['name'],
        desc: tasksMaps[i]['desc'],
        estimate: Duration(seconds: tasksMaps[i]['estimate_seconds']),
        date: DateTime.parse(tasksMaps[i]['planned_date']),
        startTime: tasksMaps[i]['start_time'] != null
            ? DateTime.parse(tasksMaps[i]['start_time'])
            : null,
        endTime: tasksMaps[i]['end_time'] != null
            ? DateTime.parse(tasksMaps[i]['end_time'])
            : null,
      );
    });
  }
}
