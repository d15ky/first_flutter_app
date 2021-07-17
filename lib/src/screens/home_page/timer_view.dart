import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'providers/timer_provider.dart';

import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:provider/provider.dart';

class TimerView extends StatelessWidget {
  final int flex;
  const TimerView({Key? key, this.flex = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerViewData = Provider.of<TimerViewData>(context, listen: false);

    Widget _timer() {
      Widget _timerPlayButton() => IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              timerViewData.timerPlay();
            },
          );

      Widget _timerPauseButton() => IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              timerViewData.timerPause();
              // PROVIDER
              // setState(() {});
            },
          );

      Widget _timerPlayPauseButton() {
        if (timerViewData.isRunning) return _timerPauseButton();
        return _timerPlayButton();
      }

      Widget _timerStopButton() => IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {
              if (timerViewData.isRunning) timerViewData.timerStop();
              timerViewData.setCurrentTask = null;
            },
          );

      return StreamBuilder<int>(
        stream: timerViewData.getWatchInstance.rawTime,
        initialData: timerViewData.getWatchInstance.rawTime.value,
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

    if (timerViewData.currentTask == null) return Container();
    return Column(
      children: [
        Text(timerViewData.currentTask!.name!),
        Text(timerViewData.currentTask!.desc!),
        _timer(),
      ],
    );
  }
}
