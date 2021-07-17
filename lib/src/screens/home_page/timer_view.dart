import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:task_list_1/src/database/tasks_data_provider.dart';

import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:provider/provider.dart';

class TimerView extends StatelessWidget {
  final int flex;
  const TimerView({Key? key, this.flex = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksViewData = Provider.of<TasksViewData>(context);

    Widget _timer() {
      Widget _timerPlayButton() => IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              tasksViewData.stopWatchTimer.onExecute
                  .add(StopWatchExecute.start);
              tasksViewData.updateListeners();
              // PROVIDER
              // setState(() {});
            },
          );

      Widget _timerPauseButton() => IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              tasksViewData.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              tasksViewData.updateListeners();
              // PROVIDER
              // setState(() {});
            },
          );

      Widget _timerPlayPauseButton() {
        if (tasksViewData.stopWatchTimer.isRunning) return _timerPauseButton();
        return _timerPlayButton();
      }

      Widget _timerStopButton() => IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {
              if (tasksViewData.stopWatchTimer.isRunning)
                tasksViewData.stopWatchTimer.onExecute
                    .add(StopWatchExecute.stop);
              tasksViewData.setCurrentTask = null;
              // PROVIDER
              // setState(() {});
            },
          );

      return StreamBuilder<int>(
        stream: tasksViewData.stopWatchTimer.rawTime,
        initialData: tasksViewData.stopWatchTimer.rawTime.value,
        builder: (context, snapshot) {
          final value = snapshot.data!;
          final displayTime =
              StopWatchTimer.getDisplayTime(value, milliSecond: false);
          return Column(children: [
            Text(displayTime),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timerPlayPauseButton(),
                _timerStopButton(),
              ],
            )
          ]);
        },
      );
    }

    if (tasksViewData.currentTask == null) return Container();
    return Column(
      children: [
        Text(tasksViewData.currentTask!.name!),
        Text(tasksViewData.currentTask!.desc!),
        _timer(),
      ],
    );
  }
}
