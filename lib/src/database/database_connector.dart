import 'dart:async';

import 'package:task_list_1/models/task.dart';
import 'package:task_list_1/models/task_execution.dart';
import 'package:task_list_1/src/tasks_fake_debug_data.dart';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:sqlite3/sqlite3.dart' hide Database;

import 'package:flutter/widgets.dart';

const tasksExecutionsTableName = 'task_executions';
const tasksTableName = 'tasks';

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

      // debug
      for (final task in tasks) {
        database!.insert(tasksTableName, task.toMap());
      }
      for (final taskExec in taskExecutions) {
        database!.insert(tasksExecutionsTableName, taskExec.toMap());
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

  Future<void> insertTaskExec(TaskExec taskExec) async {
    await checkConnection();
    await database!.insert(tasksExecutionsTableName, taskExec.toMap());
  }

  Future<void> updateTaskExec(TaskExec taskExec) async {
    await checkConnection();
    await database!.update(tasksExecutionsTableName, taskExec.toMap(),
        where: "id = ?", whereArgs: [taskExec.id]);
  }

  Future<void> deleteTaskExec(int taskExecId) async {
    await checkConnection();
    await database!.delete(tasksExecutionsTableName,
        where: "id = ?", whereArgs: [taskExecId]);
  }

  Future<List<TaskExec>> getTasksExecutions({DateTime? dayFilter}) async {
    await checkConnection();
    // TODO custom raw Query
    String taskExecSelect = "";
    for (final columnName in TaskExec().toMap().keys) {
      taskExecSelect += " $tasksExecutionsTableName.$columnName";
    }
    final List<Map<String, dynamic>> tasksExecMaps =
        await database!.rawQuery("""SELECT $taskExecSelect FROM 
        $tasksExecutionsTableName 
        LEFT JOIN $tasksTableName 
        ON $tasksExecutionsTableName.task_id = $tasksTableName.id""");
    print(tasksExecMaps);
    return [];
    return List.generate(tasksExecMaps.length, (i) {
      // todo error management and null check
      return TaskExec(
        id: tasksExecMaps[i]['id'],
        taskId: tasksExecMaps[i]['task_id'],
        date: DateTime.parse(tasksExecMaps[i]['planned_date']),
        startTime: tasksExecMaps[i]['start_time'] != null
            ? DateTime.parse(tasksExecMaps[i]['start_time'])
            : null,
        endTime: tasksExecMaps[i]['end_time'] != null
            ? DateTime.parse(tasksExecMaps[i]['end_time'])
            : null,
        duration: Duration(seconds: tasksExecMaps[i]['duration_seconds']),
      );
    });
  }

  Future<void> insertTask(Task task) async {
    await checkConnection();
    await database!.insert(tasksTableName, task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await checkConnection();
    await database!.update(tasksTableName, task.toMap(),
        where: "id = ?", whereArgs: [task.id]);
  }

  Future<void> deleteTask(int taskId) async {
    await checkConnection();
    await database!
        .delete(tasksTableName, where: "id = ?", whereArgs: [taskId]);
  }

  Future<List<Task>> getTasks({DateTime? dayFilter}) async {
    await checkConnection();
    // final List<Map<String, dynamic>> tasksMaps = (dayFilter != null)
    //     ? await database!.query(tasksTableName,
    //         where: "date(planned_date) = ?",
    //         whereArgs: [DateFormat('yyyy-MM-dd').format(dayFilter)],
    //         orderBy: "planned_date")
    //     : await database!.query(tasksTableName, orderBy: "planned_date");
    final List<Map<String, dynamic>> tasksMaps =
        await database!.query(tasksTableName, orderBy: "created_at");
    return List.generate(tasksMaps.length, (i) {
      // todo error management and null check
      return Task(
        id: tasksMaps[i]['id'],
        name: tasksMaps[i]['name'],
        desc: tasksMaps[i]['desc'],
        estimate: Duration(seconds: tasksMaps[i]['estimate_seconds']),
      );
    });
  }
}
