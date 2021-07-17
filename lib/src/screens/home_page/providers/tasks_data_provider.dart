import 'package:flutter/foundation.dart';
import 'package:task_list_1/models/task.dart';
import 'package:task_list_1/src/database/database_connector.dart';

class TasksViewData with ChangeNotifier {
  static DatabaseConnector dbCon = DatabaseConnector();
  DateTime currentDay = DateTime.now();

  set setCurrentDay(DateTime date) {
    currentDay = date;
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
