import 'package:flutter/foundation.dart';
import 'package:task_list_1/models/task.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TimerViewData with ChangeNotifier {
  final _stopWatchTimer = StopWatchTimer();
  Task? currentTask;

  set setCurrentTask(Task? task) {
    currentTask = task;
    notifyListeners();
  }

  StopWatchTimer get getWatchInstance {
    return _stopWatchTimer;
  }

  bool get isRunning {
    return _stopWatchTimer.isRunning;
  }

  void timerPlay() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    notifyListeners();
  }

  void timerPause() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    notifyListeners();
  }

  void timerStop() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    notifyListeners();
  }

  void updateListeners() {
    notifyListeners();
  }
}
