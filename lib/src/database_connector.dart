import 'dart:async';

import '../models/task.dart';
import 'tasks.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/widgets.dart';

class DatabaseConnector {
  Database? database;

  // DatabaseConnector();

  Future<void> init() async {
    print(
        "Connecting to database ${join(await getDatabasesPath(), 'tasks_list.db')}");
    WidgetsFlutterBinding.ensureInitialized();
    database = await openDatabase(
      join(await getDatabasesPath(), 'tasks_list.db'),
      onCreate: (db, version) {
        print("creating db");
        db.execute("""
            CREATE TABLE tasks(
              id INTEGER PRIMARY KEY, 
              name TEXT NOT NULL, 
              desc TEXT, 
              estimate_seconds INTEGER, 
              planned_date DATETIME, 
              start_time DATETIME, 
              end_time DATETIME);
            """);
        print("Db created");
        for (final task in tasks) {
          db.insert('tasks', task.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        print("Database initialized successfully");
        return null;
      },
      version: 1,
    );
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

  Future<List<Task>> getTasks() async {
    await checkConnection();
    final List<Map<String, dynamic>> tasksMaps = await database!.query('tasks');
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
