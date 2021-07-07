import 'package:flutter/foundation.dart';
import 'models/task.dart';
import 'src/database_connector.dart';

class TasksListData with ChangeNotifier {
  DatabaseConnector dbCon = DatabaseConnector();

  Future<List<Task>> getTasks() async {
    return dbCon.getTasks();
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
