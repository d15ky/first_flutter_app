import 'package:flutter/foundation.dart';
import 'models/task.dart';
import 'src/database_connector.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TasksViewData with ChangeNotifier {
  static DatabaseConnector dbCon = DatabaseConnector();
  final stopWatchTimer = StopWatchTimer();
  DateTime currentDay = DateTime.now();
  Task? currentTask;

  set setCurrentDay(DateTime date) {
    currentDay = date;
    notifyListeners();
  }

  set setCurrentTask(Task? task) {
    currentTask = task;
    notifyListeners();
  }

  void updateListeners() {
    notifyListeners();
  }

  Future<List<Task>> getTasks({DateTime? dayFilter}) async {
    return dbCon.getTasks(dayFilter: dayFilter);
  }

  Future<void> deleteTask(int taskId) async {
    final del = dbCon.deleteTask(taskId);
    notifyListeners();
    return del;
  }

  Future<void> insertTask(Task task) async {
    final ins = dbCon.insertTask(task);
    notifyListeners();
    return ins;
  }

  Future<void> updateTask(Task task) async {
    final upd = dbCon.updateTask(task);
    notifyListeners();
    return upd;
  }
}
