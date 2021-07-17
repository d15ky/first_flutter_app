import 'package:task_list_1/models/task.dart';
import 'package:task_list_1/src/database/tasks_data_provider.dart';
import 'package:task_list_1/src/screens/change_task/change_task_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
        // Now child takes all the available width space
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
        return RefreshIndicator(
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
            child: _showLoadingOrData(snapshot),
          );
        });
  }
}
