import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:task_list_1/src/database_connector.dart';
import 'package:task_list_1/tasks_data_provider.dart';
import 'models/task.dart';
import 'add_task_screen.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TaskListView extends StatelessWidget {
  // final List<Task> tasks;
  final int flex;

  const TaskListView({
    Key? key,
    this.flex = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksViewData = Provider.of<TasksViewData>(context);

    Widget _playPauseTaskButton(Task task) {
      Widget _playTaskButton() {
        return IconButton(
            onPressed: () {
              // PROVIDER
              if (tasksViewData.currentTask?.id != task.id)
                tasksViewData.currentTask = task;
              tasksViewData.stopWatchTimer.onExecute
                  .add(StopWatchExecute.start);
              tasksViewData.updateListeners();
              // setState(() {});
            },
            icon: Icon(Icons.play_circle_outlined, color: Colors.green));
      }

      Widget _pauseTaskButton() {
        return IconButton(
            onPressed: () {
              // PROVIDER
              tasksViewData.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              tasksViewData.updateListeners();
              // setState(() {});
            },
            icon: Icon(Icons.pause_circle_outlined, color: Colors.amber));
      }

      if (tasksViewData.stopWatchTimer.isRunning &&
          task.id == tasksViewData.currentTask?.id) return _pauseTaskButton();
      return _playTaskButton();
    }

    Widget _infoTaskButton(Task task) {
      return IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeTaskScreen(task: task)));
            // ADD PROVIDER
            // setState(() {});
          },
          icon: Icon(Icons.info_outline, color: Colors.blue));
    }

    Widget _deleteTaskButton(Task task) {
      return IconButton(
          onPressed: () {
            showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Are you sure you want to delete"),
                        Text("\"${task.name}\"?"),
                      ],
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          // PROVIDER
                          tasksViewData.deleteTask(task.id!);
                          Navigator.of(context).pop();
                          // setState(() {});
                        },
                        isDestructiveAction: true,
                        isDefaultAction: true,
                      ),
                      CupertinoDialogAction(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
                barrierDismissible: true);
          },
          icon: Icon(Icons.delete_forever, color: Colors.red));
    }

    Widget _clickableChangeTask(Task task, {required Widget child}) {
      return GestureDetector(
        onTap: () {
          if (tasksViewData.stopWatchTimer.isRunning) return;
          tasksViewData.setCurrentTask = task;
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
            alignment: Alignment.center, width: double.infinity, child: child),
      );
    }

    Widget _buildTaskTile(Task task) {
      return ExpansionTile(
        key: Key("homePageTask:${task.id}"),
        title: Row(children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.blue[100],
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(DateFormat('HH:mm').format(task.date!)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(task.name!),
          )
        ]),
        onExpansionChanged: (isOpening) {
          if (!isOpening || tasksViewData.stopWatchTimer.isRunning) return;
          tasksViewData.setCurrentTask = task;
          // PROVIDER setState(() {});
        },
        children: [
          _clickableChangeTask(task, child: Text(task.desc!)),
          _clickableChangeTask(
            task,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playPauseTaskButton(task),
                // _stopTaskButton(),
                _infoTaskButton(task),
                _deleteTaskButton(task),
              ],
            ),
          ),
        ],
      );
    }

    void _currentDayPickerPopUp() {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            DateTime tempValue = tasksViewData.currentDay;
            return BottomSheet(
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tasksViewData.currentDay,
                      onDateTimeChanged: (DateTime date) {
                        tempValue = date;
                      },
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        if (tasksViewData.currentDay != tempValue)
                          tasksViewData.setCurrentDay = tempValue;
                        Navigator.pop(context);
                      },
                      child: Text('Ok')),
                ],
              ),
              onClosing: () {},
            );
          });
    }

    Widget _currentDayButton() {
      return InkWell(
        onTap: () => _currentDayPickerPopUp(),
        child: Container(
            height: 20,
            width: 200,
            decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.blue[300],
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Center(
                child: Text(DateFormat('dd.MM.yyyy')
                    .format(tasksViewData.currentDay)))),
      );
    }

    Widget _showLoadingOrData(AsyncSnapshot<List<Task>> snapshot) {
      if (snapshot.hasData) {
        final _tasks = snapshot.data!;
        return Container(
          decoration: BoxDecoration(border: Border.all()),
          child: RefreshIndicator(
            onRefresh: () async {
              tasksViewData.updateListeners();
              // Provider setState
              return;
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _currentDayButton(),
                ),
                Flexible(
                  child: ListView(
                    children: _tasks.map(_buildTaskTile).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(
          child: SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ));
    }

    return FutureBuilder<List<Task>>(
        future: tasksViewData.getTasks(dayFilter: tasksViewData.currentDay),
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          return Expanded(
            flex: flex,
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: _showLoadingOrData(snapshot),
            ),
          );
        });
  }
}

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

class NewHomePage extends StatelessWidget {
  final String title;

  const NewHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = TasksViewData();
    return ChangeNotifierProvider(
      create: (_) => notificationProvider,
      child: Scaffold(
          appBar: AppBar(title: Text(title), actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final added = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddTaskScreen()));
                if (added == true) {
                  notificationProvider.updateListeners();
                  // PROVIDER NOTIFY
                  // setState(() {});
                }
              },
            ),
          ]),
          body: SafeArea(
            child: Column(
              children: [
                Consumer<TasksViewData>(
                    builder: (context, data, child) => TimerView()),
                Consumer<TasksViewData>(
                    builder: (context, data, child) => TaskListView(flex: 5)),
              ],
            ),
          )),
    );
  }
}
